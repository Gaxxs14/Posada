namespace Posada.Application.DTOs;

public record DashboardStatsDto(
    int TotalRooms,
    int AvailableRooms,
    int OccupiedRooms,
    int CleaningRooms,
    int MaintenanceRooms,
    decimal OccupancyRatePercentage,
    int PendingBookings,
    int ActiveCheckInsToday,
    int ExpectedCheckOutsToday,
    decimal MonthlyRevenueUsd,
    decimal MonthlyRevenueVes,
    decimal TodayRevenueUsd,
    List<MonthlyRevenueDto> RevenueLast6Months,
    List<RoomStatusSummaryDto> RoomsSummary
);

public record MonthlyRevenueDto(
    string Month,
    decimal RevenueUsd,
    decimal RevenueVes,
    int TotalBookings
);

public record RoomStatusSummaryDto(
    string RoomNumber,
    string Title,
    string Status,
    string? CurrentGuestName,
    DateTime? CheckOutDate
);
