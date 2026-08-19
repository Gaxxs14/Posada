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
        try
        {
            var totalRooms = await _context.Rooms.CountAsync(r => r.IsActive);
            var availableRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.Available && r.IsActive);
            var occupiedRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.Occupied && r.IsActive);
            var cleaningRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.NeedsCleaning && r.IsActive);
            var maintenanceRooms = await _context.Rooms.CountAsync(r => r.Status == RoomStatus.UnderMaintenance && r.IsActive);

            decimal occupancyRate = totalRooms > 0 ? ((decimal)occupiedRooms / totalRooms) * 100m : 0m;

            var pendingBookings = await _context.Bookings.CountAsync(b => b.Status == BookingStatus.Pending);

            var now = DateTime.UtcNow;
            var todayStart = new DateTime(now.Year, now.Month, now.Day, 0, 0, 0, DateTimeKind.Utc);
            var tomorrowStart = todayStart.AddDays(1);

            var activeCheckInsToday = await _context.Bookings.CountAsync(b => b.CheckInDate >= todayStart && b.CheckInDate < tomorrowStart && b.Status == BookingStatus.Confirmed);
            var expectedCheckOutsToday = await _context.Bookings.CountAsync(b => b.CheckOutDate >= todayStart && b.CheckOutDate < tomorrowStart && b.Status == BookingStatus.CheckedIn);

            var settings = await _context.HotelSettings.FirstOrDefaultAsync();
            var exchangeRate = settings != null && settings.UsdExchangeRateBcv > 0 ? settings.UsdExchangeRateBcv : 765.0m;

            // Current Month Revenue
            var firstDayOfMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
            var monthlyPayments = await _context.Payments
                .Where(p => p.Status == PaymentStatus.Approved && p.CreatedAt >= firstDayOfMonth)
                .ToListAsync();

            var monthlyRevenueUsd = monthlyPayments.Sum(p => p.AmountUsd);
            var monthlyRevenueVes = monthlyRevenueUsd * exchangeRate;

            // Today Revenue
            var todayRevenueUsd = monthlyPayments.Where(p => p.CreatedAt >= todayStart && p.CreatedAt < tomorrowStart).Sum(p => p.AmountUsd);

            // Revenue Last 6 Months
            var revenueLast6Months = new List<MonthlyRevenueDto>();
            for (int i = 5; i >= 0; i--)
            {
                var monthDate = now.AddMonths(-i);
                var start = new DateTime(monthDate.Year, monthDate.Month, 1, 0, 0, 0, DateTimeKind.Utc);
                var end = start.AddMonths(1);

                var monthPaymentsSum = await _context.Payments
                    .Where(p => p.Status == PaymentStatus.Approved && p.CreatedAt >= start && p.CreatedAt < end)
                    .SumAsync(p => (decimal?)p.AmountUsd) ?? 0m;

                var monthBookingsCount = await _context.Bookings
                    .Where(b => b.CreatedAt >= start && b.CreatedAt < end)
                    .CountAsync();

                var monthName = start.ToString("MMM yyyy", CultureInfo.InvariantCulture);
                revenueLast6Months.Add(new MonthlyRevenueDto(
                    monthName,
                    monthPaymentsSum,
                    monthPaymentsSum * exchangeRate,
                    monthBookingsCount
                ));
            }

            // Room status summary safely separated
            var allRooms = await _context.Rooms
                .Where(r => r.IsActive)
                .OrderBy(r => r.RoomNumber)
                .ToListAsync();

            var activeBookings = await _context.Bookings
                .Include(b => b.Guest)
                .Where(b => b.Status == BookingStatus.CheckedIn)
                .ToListAsync();

            var roomsWithActiveBooking = allRooms.Select(r =>
            {
                var activeBooking = activeBookings.FirstOrDefault(b => b.RoomId == r.Id);
                return new RoomStatusSummaryDto(
                    r.RoomNumber,
                    r.Title,
                    r.Status.ToString(),
                    activeBooking?.Guest?.FullName,
                    activeBooking?.CheckOutDate
                );
            }).ToList();

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
        catch (Exception ex)
        {
            return ApiResponse<DashboardStatsDto>.Fail($"Error en DashboardService: {ex.Message}");
        }
    }
}
