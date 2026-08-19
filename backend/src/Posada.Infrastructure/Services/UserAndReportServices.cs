using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;
using Posada.Domain.Enums;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class UserService : IUserService
{
    private readonly AppDbContext _context;

    public UserService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<UserListItemDto>>> GetAllUsersAsync(UserRole? role = null)
    {
        var query = _context.Users.AsQueryable();

        if (role.HasValue)
        {
            query = query.Where(u => u.Role == role.Value);
        }

        var users = await query
            .OrderByDescending(u => u.CreatedAt)
            .Select(u => new UserListItemDto
            {
                Id = u.Id,
                FullName = u.FullName,
                Username = u.Username,
                Email = u.Email,
                PhoneNumber = u.PhoneNumber,
                Role = u.Role.ToString(),
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt
            })
            .ToListAsync();

        return ApiResponse<List<UserListItemDto>>.Ok(users);
    }

    public async Task<ApiResponse<UserListItemDto>> CreateStaffUserAsync(CreateUserRequest request)
    {
        var usernameExists = await _context.Users.AnyAsync(u => u.Username.ToLower() == request.Username.ToLower());
        if (usernameExists)
        {
            return ApiResponse<UserListItemDto>.Fail("El nombre de usuario ya está registrado.");
        }

        var emailExists = await _context.Users.AnyAsync(u => u.Email.ToLower() == request.Email.ToLower());
        if (emailExists)
        {
            return ApiResponse<UserListItemDto>.Fail("El correo electrónico ya está registrado.");
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

        var user = new User
        {
            Id = Guid.NewGuid(),
            FullName = request.FullName,
            Username = request.Username,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            PasswordHash = passwordHash,
            Role = request.Role,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var dto = new UserListItemDto
        {
            Id = user.Id,
            FullName = user.FullName,
            Username = user.Username,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            Role = user.Role.ToString(),
            IsActive = user.IsActive,
            CreatedAt = user.CreatedAt
        };

        return ApiResponse<UserListItemDto>.Ok(dto, "Usuario creado exitosamente.");
    }

    public async Task<ApiResponse<UserListItemDto>> UpdateUserAsync(Guid id, UpdateUserRequest request)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return ApiResponse<UserListItemDto>.Fail("Usuario no encontrado.");
        }

        user.FullName = request.FullName;
        user.Email = request.Email;
        user.PhoneNumber = request.PhoneNumber;
        user.Role = request.Role;

        if (!string.IsNullOrWhiteSpace(request.NewPassword))
        {
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        }

        await _context.SaveChangesAsync();

        var dto = new UserListItemDto
        {
            Id = user.Id,
            FullName = user.FullName,
            Username = user.Username,
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            Role = user.Role.ToString(),
            IsActive = user.IsActive,
            CreatedAt = user.CreatedAt
        };

        return ApiResponse<UserListItemDto>.Ok(dto, "Usuario actualizado.");
    }

    public async Task<ApiResponse<bool>> ToggleUserStatusAsync(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return ApiResponse<bool>.Fail("Usuario no encontrado.");
        }

        user.IsActive = !user.IsActive;
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(user.IsActive, $"Usuario {(user.IsActive ? "activado" : "desactivado")}.");
    }

    public async Task<ApiResponse<bool>> DeleteUserAsync(Guid id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
        {
            return ApiResponse<bool>.Fail("Usuario no encontrado.");
        }

        var hasBookings = await _context.Bookings.AnyAsync(b => b.GuestId == id);
        if (hasBookings)
        {
            user.IsActive = false;
            await _context.SaveChangesAsync();
            return ApiResponse<bool>.Ok(true, "El usuario tiene reservas registradas, fue desactivado en lugar de eliminado.");
        }

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Usuario eliminado permanentemente.");
    }
}

public class ReportService : IReportService
{
    private readonly AppDbContext _context;

    public ReportService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<FinancialReportDto>> GetFinancialReportAsync(DateTime? fromDate = null, DateTime? toDate = null)
    {
        var start = fromDate ?? DateTime.UtcNow.AddMonths(-1);
        var end = toDate ?? DateTime.UtcNow;

        var payments = await _context.Payments
            .Include(p => p.Booking)
                .ThenInclude(b => b.Guest)
            .Where(p => p.CreatedAt >= start && p.CreatedAt <= end && p.Status == PaymentStatus.Approved)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        var completedBookings = await _context.Bookings
            .CountAsync(b => b.CreatedAt >= start && b.CreatedAt <= end && b.Status == BookingStatus.CheckedOut);

        var totalUsd = payments.Sum(p => p.AmountUsd);
        var totalVes = payments.Sum(p => p.AmountVes);

        var byMethod = payments
            .GroupBy(p => p.Method.ToString())
            .Select(g => new RevenueByMethodDto
            {
                Method = g.Key,
                TotalUsd = g.Sum(p => p.AmountUsd),
                TransactionsCount = g.Count()
            })
            .ToList();

        var recent = payments.Take(20).Select(p => new PaymentSummaryItemDto
        {
            Id = p.Id,
            BookingCode = p.Booking.BookingCode,
            GuestName = p.Booking.Guest.FullName,
            AmountUsd = p.AmountUsd,
            AmountVes = p.AmountVes,
            Method = p.Method.ToString(),
            ReferenceNumber = p.ReferenceNumber,
            CreatedAt = p.CreatedAt
        }).ToList();

        var report = new FinancialReportDto
        {
            FromDate = start,
            ToDate = end,
            TotalRevenueUsd = totalUsd,
            TotalRevenueVes = totalVes,
            TotalBookingsCompleted = completedBookings,
            TotalPaymentsCount = payments.Count,
            RevenueByPaymentMethod = byMethod,
            RecentPayments = recent
        };

        return ApiResponse<FinancialReportDto>.Ok(report);
    }

    public async Task<ApiResponse<OccupancyReportDto>> GetOccupancyReportAsync(DateTime? fromDate = null, DateTime? toDate = null)
    {
        var start = fromDate ?? DateTime.UtcNow.AddMonths(-1);
        var end = toDate ?? DateTime.UtcNow;

        var totalRooms = await _context.Rooms.CountAsync(r => r.IsActive);
        var bookings = await _context.Bookings
            .Include(b => b.Room)
            .Where(b => b.CheckInDate >= start && b.CheckOutDate <= end && (b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.CheckedIn || b.Status == BookingStatus.CheckedOut))
            .ToListAsync();

        var totalDays = Math.Max(1, (int)(end - start).TotalDays);
        var totalCapacityNights = totalRooms * totalDays;
        var totalNightsSold = bookings.Sum(b => b.TotalNights);

        var avgOccupancy = totalCapacityNights > 0 
            ? Math.Min(100.0, Math.Round((double)totalNightsSold / totalCapacityNights * 100, 1)) 
            : 0.0;

        var roomBreakdown = bookings
            .GroupBy(b => b.Room)
            .Select(g => new RoomOccupancyItemDto
            {
                RoomNumber = g.Key.RoomNumber,
                RoomTitle = g.Key.Title,
                Type = g.Key.Type.ToString(),
                NightsSold = g.Sum(b => b.TotalNights),
                RevenueGeneratedUsd = g.Sum(b => b.TotalAmountUsd)
            })
            .OrderByDescending(r => r.RevenueGeneratedUsd)
            .ToList();

        var report = new OccupancyReportDto
        {
            FromDate = start,
            ToDate = end,
            TotalRoomsAvailable = totalRooms,
            TotalNightsSold = totalNightsSold,
            AverageOccupancyRate = avgOccupancy,
            RoomBreakdown = roomBreakdown
        };

        return ApiResponse<OccupancyReportDto>.Ok(report);
    }
}
