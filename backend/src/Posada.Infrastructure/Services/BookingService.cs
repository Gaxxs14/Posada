using System.Security.Cryptography;
using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;
using Posada.Domain.Enums;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class BookingService : IBookingService
{
    private readonly AppDbContext _context;

    public BookingService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<BookingQuoteResponse>> GetQuoteAsync(BookingQuoteRequest request)
    {
        var room = await _context.Rooms.FindAsync(request.RoomId);
        if (room == null || !room.IsActive)
        {
            return ApiResponse<BookingQuoteResponse>.Fail("La habitación seleccionada no está disponible.");
        }

        var checkIn = request.CheckInDate.Date;
        var checkOut = request.CheckOutDate.Date;

        if (checkOut <= checkIn)
        {
            return ApiResponse<BookingQuoteResponse>.Fail("La fecha de salida debe ser posterior a la fecha de entrada.");
        }

        var totalNights = (int)(checkOut - checkIn).TotalDays;
        if (totalNights <= 0) totalNights = 1;

        // Check availability (Overbooking prevention)
        var hasConflict = await _context.Bookings.AnyAsync(b =>
            b.RoomId == request.RoomId &&
            (b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.CheckedIn || b.Status == BookingStatus.Pending) &&
            checkIn < b.CheckOutDate.Date && checkOut > b.CheckInDate.Date
        );

        var settings = await _context.HotelSettings.FirstOrDefaultAsync() ?? new HotelSetting();
        var totalUsd = room.PricePerNightUsd * totalNights;
        var totalVes = totalUsd * settings.UsdExchangeRateBcv;

        var quote = new BookingQuoteResponse(
            room.Id,
            room.RoomNumber,
            room.Title,
            checkIn,
            checkOut,
            totalNights,
            room.PricePerNightUsd,
            totalUsd,
            settings.UsdExchangeRateBcv,
            totalVes,
            !hasConflict
        );

        return ApiResponse<BookingQuoteResponse>.Ok(quote);
    }

    public async Task<ApiResponse<BookingDto>> CreateBookingAsync(Guid guestId, CreateBookingRequest request)
    {
        var checkIn = request.CheckInDate.Date;
        var checkOut = request.CheckOutDate.Date;

        if (checkOut <= checkIn)
        {
            return ApiResponse<BookingDto>.Fail("La fecha de salida debe ser posterior a la fecha de entrada.");
        }

        var room = await _context.Rooms.FindAsync(request.RoomId);
        if (room == null || !room.IsActive)
        {
            return ApiResponse<BookingDto>.Fail("Habitación no válida.");
        }

        if (request.GuestsCount > room.Capacity)
        {
            return ApiResponse<BookingDto>.Fail($"La capacidad máxima de la habitación es de {room.Capacity} personas.");
        }

        // Overbooking validation in atomic check
        var hasConflict = await _context.Bookings.AnyAsync(b =>
            b.RoomId == request.RoomId &&
            (b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.CheckedIn || b.Status == BookingStatus.Pending) &&
            checkIn < b.CheckOutDate.Date && checkOut > b.CheckInDate.Date
        );

        if (hasConflict)
        {
            return ApiResponse<BookingDto>.Fail("La habitación ya se encuentra reservada u ocupada en el rango de fechas seleccionado.");
        }

        var settings = await _context.HotelSettings.FirstOrDefaultAsync() ?? new HotelSetting();
        var totalNights = (int)(checkOut - checkIn).TotalDays;
        if (totalNights <= 0) totalNights = 1;
        var totalAmountUsd = room.PricePerNightUsd * totalNights;

        var bookingCode = GenerateBookingCode();

        var booking = new Booking
        {
            Id = Guid.NewGuid(),
            BookingCode = bookingCode,
            GuestId = guestId,
            RoomId = room.Id,
            CheckInDate = checkIn,
            CheckOutDate = checkOut,
            TotalNights = totalNights,
            GuestsCount = request.GuestsCount,
            PricePerNightUsd = room.PricePerNightUsd,
            TotalAmountUsd = totalAmountUsd,
            ExchangeRateUsed = settings.UsdExchangeRateBcv,
            Status = BookingStatus.Pending,
            SpecialRequests = request.SpecialRequests?.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        if (request.InitialPaymentMethod.HasValue && !string.IsNullOrWhiteSpace(request.PaymentReference))
        {
            var payment = new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = booking.Id,
                AmountUsd = totalAmountUsd,
                AmountVes = totalAmountUsd * settings.UsdExchangeRateBcv,
                ExchangeRate = settings.UsdExchangeRateBcv,
                Method = request.InitialPaymentMethod.Value,
                ReferenceNumber = request.PaymentReference.Trim(),
                Status = PaymentStatus.Pending,
                CreatedAt = DateTime.UtcNow
            };
            booking.Payments.Add(payment);
        }

        _context.Bookings.Add(booking);
        await _context.SaveChangesAsync();

        var created = await GetBookingByIdAsync(booking.Id);
        return ApiResponse<BookingDto>.Ok(created.Data!, "Reservación creada exitosamente.");
    }

    public async Task<ApiResponse<List<BookingDto>>> GetUserBookingsAsync(Guid guestId)
    {
        var bookings = await _context.Bookings
            .Include(b => b.Guest)
            .Include(b => b.Room)
            .Include(b => b.Payments)
            .Include(b => b.ExtraCharges)
            .Where(b => b.GuestId == guestId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();

        var dtos = bookings.Select(MapToDto).ToList();
        return ApiResponse<List<BookingDto>>.Ok(dtos);
    }

    public async Task<ApiResponse<List<BookingDto>>> GetAllBookingsAsync(BookingStatus? status = null, DateTime? date = null)
    {
        var query = _context.Bookings
            .Include(b => b.Guest)
            .Include(b => b.Room)
            .Include(b => b.Payments)
            .Include(b => b.ExtraCharges)
            .AsQueryable();

        if (status.HasValue)
        {
            query = query.Where(b => b.Status == status.Value);
        }

        if (date.HasValue)
        {
            var target = date.Value.Date;
            query = query.Where(b => b.CheckInDate.Date <= target && b.CheckOutDate.Date >= target);
        }

        var bookings = await query
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();

        var dtos = bookings.Select(MapToDto).ToList();
        return ApiResponse<List<BookingDto>>.Ok(dtos);
    }

    public async Task<ApiResponse<BookingDto>> GetBookingByCodeAsync(string bookingCode)
    {
        var booking = await _context.Bookings
            .Include(b => b.Guest)
            .Include(b => b.Room)
            .Include(b => b.Payments)
            .Include(b => b.ExtraCharges)
            .FirstOrDefaultAsync(b => b.BookingCode.ToLower() == bookingCode.Trim().ToLower());

        if (booking == null)
        {
            return ApiResponse<BookingDto>.Fail("Reservación no encontrada.");
        }

        return ApiResponse<BookingDto>.Ok(MapToDto(booking));
    }

    public async Task<ApiResponse<BookingDto>> GetBookingByIdAsync(Guid id)
    {
        var booking = await _context.Bookings
            .Include(b => b.Guest)
            .Include(b => b.Room)
            .Include(b => b.Payments)
            .Include(b => b.ExtraCharges)
            .FirstOrDefaultAsync(b => b.Id == id);

        if (booking == null)
        {
            return ApiResponse<BookingDto>.Fail("Reservación no encontrada.");
        }

        return ApiResponse<BookingDto>.Ok(MapToDto(booking));
    }

    public async Task<ApiResponse<BookingDto>> UpdateBookingStatusAsync(Guid id, UpdateBookingStatusRequest request, Guid currentUserId)
    {
        var booking = await _context.Bookings
            .Include(b => b.Room)
            .Include(b => b.Payments)
            .FirstOrDefaultAsync(b => b.Id == id);

        if (booking == null)
        {
            return ApiResponse<BookingDto>.Fail("Reservación no encontrada.");
        }

        booking.Status = request.Status;
        if (!string.IsNullOrWhiteSpace(request.AdminNotes))
        {
            booking.AdminNotes = request.AdminNotes;
        }

        if (request.Status == BookingStatus.Confirmed)
        {
            // Auto approve pending payments
            foreach (var p in booking.Payments.Where(p => p.Status == PaymentStatus.Pending))
            {
                p.Status = PaymentStatus.Approved;
                p.ApprovedByUserId = currentUserId;
                p.ProcessedAt = DateTime.UtcNow;
            }
        }
        else if (request.Status == BookingStatus.Cancelled)
        {
            if (booking.Room.Status == RoomStatus.Occupied)
            {
                booking.Room.Status = RoomStatus.Available;
            }
        }

        await _context.SaveChangesAsync();
        var updated = await GetBookingByIdAsync(id);
        return ApiResponse<BookingDto>.Ok(updated.Data!, "Estado de reservación actualizado.");
    }

    public async Task<ApiResponse<BookingDto>> CheckInAsync(Guid bookingId, Guid receptionistId)
    {
        var booking = await _context.Bookings
            .Include(b => b.Room)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null)
        {
            return ApiResponse<BookingDto>.Fail("Reservación no encontrada.");
        }

        if (booking.Status == BookingStatus.Cancelled)
        {
            return ApiResponse<BookingDto>.Fail("No se puede realizar Check-in de una reservación cancelada.");
        }

        booking.Status = BookingStatus.CheckedIn;
        booking.CheckedInAt = DateTime.UtcNow;
        booking.Room.Status = RoomStatus.Occupied;

        await _context.SaveChangesAsync();
        var updated = await GetBookingByIdAsync(bookingId);
        return ApiResponse<BookingDto>.Ok(updated.Data!, "Check-in realizado exitosamente. Habitación marcada como Ocupada.");
    }

    public async Task<ApiResponse<BookingDto>> CheckOutAsync(Guid bookingId, Guid receptionistId)
    {
        var booking = await _context.Bookings
            .Include(b => b.Room)
            .Include(b => b.Payments)
            .Include(b => b.ExtraCharges)
            .FirstOrDefaultAsync(b => b.Id == bookingId);

        if (booking == null)
        {
            return ApiResponse<BookingDto>.Fail("Reservación no encontrada.");
        }

        var totalPaid = booking.Payments.Where(p => p.Status == PaymentStatus.Approved).Sum(p => p.AmountUsd);
        var totalExtras = booking.ExtraCharges.Sum(e => e.AmountUsd * e.Quantity);
        var grandTotal = booking.TotalAmountUsd + totalExtras;

        if (totalPaid < grandTotal)
        {
            var pendingAmount = grandTotal - totalPaid;
            // Note: In real life you can either block or alert
        }

        booking.Status = BookingStatus.CheckedOut;
        booking.CheckedOutAt = DateTime.UtcNow;
        // Mark room for housekeeping!
        booking.Room.Status = RoomStatus.NeedsCleaning;

        await _context.SaveChangesAsync();
        var updated = await GetBookingByIdAsync(bookingId);
        return ApiResponse<BookingDto>.Ok(updated.Data!, "Check-out realizado exitosamente. Habitación enviada a Limpieza.");
    }

    public async Task<ApiResponse<PaymentDto>> AddPaymentAsync(Guid bookingId, ProcessPaymentRequest request, Guid currentUserId)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null)
        {
            return ApiResponse<PaymentDto>.Fail("Reservación no encontrada.");
        }

        var settings = await _context.HotelSettings.FirstOrDefaultAsync() ?? new HotelSetting();
        var payment = new Payment
        {
            Id = Guid.NewGuid(),
            BookingId = bookingId,
            AmountUsd = request.AmountUsd,
            AmountVes = request.AmountUsd * settings.UsdExchangeRateBcv,
            ExchangeRate = settings.UsdExchangeRateBcv,
            Method = request.Method,
            ReferenceNumber = request.ReferenceNumber.Trim(),
            ReceiptUrl = request.ReceiptUrl,
            Status = PaymentStatus.Approved,
            ApprovedByUserId = currentUserId,
            ProcessedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };

        _context.Payments.Add(payment);
        await _context.SaveChangesAsync();

        var dto = new PaymentDto(
            payment.Id,
            payment.BookingId,
            payment.AmountUsd,
            payment.AmountVes,
            payment.ExchangeRate,
            payment.Method,
            payment.ReferenceNumber,
            payment.ReceiptUrl,
            payment.Status,
            payment.CreatedAt
        );

        return ApiResponse<PaymentDto>.Ok(dto, "Pago registrado y acreditado exitosamente.");
    }

    public async Task<ApiResponse<ExtraChargeDto>> AddExtraChargeAsync(Guid bookingId, AddExtraChargeRequest request)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null)
        {
            return ApiResponse<ExtraChargeDto>.Fail("Reservación no encontrada.");
        }

        var charge = new ExtraCharge
        {
            Id = Guid.NewGuid(),
            BookingId = bookingId,
            Description = request.Description.Trim(),
            AmountUsd = request.AmountUsd,
            Quantity = request.Quantity <= 0 ? 1 : request.Quantity,
            CreatedAt = DateTime.UtcNow
        };

        _context.ExtraCharges.Add(charge);
        await _context.SaveChangesAsync();

        var dto = new ExtraChargeDto(
            charge.Id,
            charge.BookingId,
            charge.Description,
            charge.AmountUsd,
            charge.Quantity,
            charge.TotalUsd,
            charge.CreatedAt
        );

        return ApiResponse<ExtraChargeDto>.Ok(dto, "Cargo extra agregado a la reservación.");
    }

    private static string GenerateBookingCode()
    {
        var randomNum = RandomNumberGenerator.GetInt32(1000, 9999);
        var year = DateTime.UtcNow.Year;
        return $"POS-{year}-{randomNum}";
    }

    private static BookingDto MapToDto(Booking b)
    {
        var payments = b.Payments.Select(p => new PaymentDto(
            p.Id,
            p.BookingId,
            p.AmountUsd,
            p.AmountVes,
            p.ExchangeRate,
            p.Method,
            p.ReferenceNumber,
            p.ReceiptUrl,
            p.Status,
            p.CreatedAt
        )).ToList();

        var extraCharges = b.ExtraCharges.Select(e => new ExtraChargeDto(
            e.Id,
            e.BookingId,
            e.Description,
            e.AmountUsd,
            e.Quantity,
            e.TotalUsd,
            e.CreatedAt
        )).ToList();

        var totalPaid = payments.Where(p => p.Status == PaymentStatus.Approved).Sum(p => p.AmountUsd);
        var totalExtras = extraCharges.Sum(e => e.TotalUsd);
        var grandTotalUsd = b.TotalAmountUsd + totalExtras;
        var remaining = grandTotalUsd - totalPaid;

        return new BookingDto(
            b.Id,
            b.BookingCode,
            b.GuestId,
            b.Guest?.FullName ?? "Huésped",
            b.Guest?.Email ?? string.Empty,
            b.Guest?.PhoneNumber ?? string.Empty,
            b.RoomId,
            b.Room?.RoomNumber ?? string.Empty,
            b.Room?.Title ?? string.Empty,
            b.Room?.Type ?? RoomType.Double,
            b.CheckInDate,
            b.CheckOutDate,
            b.TotalNights,
            b.GuestsCount,
            b.PricePerNightUsd,
            b.TotalAmountUsd,
            b.ExchangeRateUsed,
            b.TotalAmountUsd * b.ExchangeRateUsed,
            b.Status,
            b.SpecialRequests,
            b.AdminNotes,
            b.CreatedAt,
            b.CheckedInAt,
            b.CheckedOutAt,
            payments,
            extraCharges,
            totalPaid,
            remaining > 0 ? remaining : 0
        );
    }
}
