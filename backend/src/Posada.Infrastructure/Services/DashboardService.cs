using System.Globalization;
using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Enums;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class DashboardService : IDashboardService
{
    private readonly AppDbContext _context;

    public DashboardService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<DashboardStatsDto>> GetDashboardStatsAsync()
    {
        var totalRooms = await _context.Rooms.CountAsync();
        var availableRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.Available);
        var occupiedRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.Occupied);
        var cleaningRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.NeedsCleaning);
        var maintenanceRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.UnderMaintenance);

        decimal occupancyRate = totalRooms > 0 ? ((decimal)occupiedRooms / totalRooms) * 100m : 0m;

        var pendingBookings = await _context.Bookings.CountAsync(b => b.Status == BookingStatus.Pending);

        var today = DateTime.UtcNow.Date;
        var activeCheckInsToday = await _context.Bookings.CountAsync(b => b.CheckInDate.Date == today && b.Status == BookingStatus.Confirmed);
        var expectedCheckOutsToday = await _context.Bookings.CountAsync(b => b.CheckOutDate.Date == today && b.Status == BookingStatus.CheckedIn);

        var settings = await _context.HotelSettings.FirstOrDefaultAsync() ?? new Domain.Entities.HotelSetting();
        var exchangeRate = settings.UsdExchangeRateBcv;

        // Current Month Revenue
        var firstDayOfMonth = new DateTime(today.Year, today.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var monthlyPayments = await _context.Payments
            .Where(p => p.Status == PaymentStatus.Approved && p.CreatedAt >= firstDayOfMonth)
            .ToListAsync();

        var monthlyRevenueUsd = monthlyPayments.Sum(p => p.AmountUsd);
        var monthlyRevenueVes = monthlyRevenueUsd * exchangeRate;

        // Today Revenue
        var todayRevenueUsd = monthlyPayments.Where(p => p.CreatedAt.Date == today).Sum(p => p.AmountUsd);

        // Revenue Last 6 Months
        var revenueLast6Months = new List<MonthlyRevenueDto>();
        for (int i = 5; i >= 0; i--)
        {
            var monthDate = today.AddMonths(-i);
            var start = new DateTime(monthDate.Year, monthDate.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var end = start.AddMonths(1);

            var monthPayments = await _context.Payments
                .Where(p => p.Status == PaymentStatus.Approved && p.CreatedAt >= start && p.CreatedAt < end)
                .SumAsync(p => p.AmountUsd);

            var monthBookingsCount = await _context.Bookings
                .Where(b => b.CreatedAt >= start && b.CreatedAt < end)
                .CountAsync();

            var monthName = start.ToString("MMM yyyy", CultureInfo.InvariantCulture);
            revenueLast6Months.Add(new MonthlyRevenueDto(
                monthName,
                monthPayments,
                monthPayments * exchangeRate,
                monthBookingsCount
            ));
        }

        // Room status summary
        var roomsWithActiveBooking = await _context.Rooms
            .Select(r => new RoomStatusSummaryDto(
                r.RoomNumber,
                r.Title,
                r.Status.ToString(),
                r.Bookings.Where(b => b.Status == BookingStatus.CheckedIn).Select(b => b.Guest.FullName).FirstOrDefault(),
                r.Bookings.Where(b => b.Status == BookingStatus.CheckedIn).Select(b => (DateTime?)b.CheckOutDate).FirstOrDefault()
            ))
            .OrderBy(r => r.RoomNumber)
            .ToListAsync();

        var stats = new DashboardStatsDto(
            totalRooms,
            availableRooms,
            occupiedRooms,
            cleaningRooms,
            maintenanceRooms,
            Math.Round(occupancyRate, 1),
            pendingBookings,
            activeCheckInsToday,
            expectedCheckOutsToday,
            monthlyRevenueUsd,
            monthlyRevenueVes,
            todayRevenueUsd,
            revenueLast6Months,
            roomsWithActiveBooking
        );

        return ApiResponse<DashboardStatsDto>.Ok(stats);
    }
}
