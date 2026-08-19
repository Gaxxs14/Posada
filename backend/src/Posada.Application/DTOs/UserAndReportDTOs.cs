using Posada.Domain.Enums;

namespace Posada.Application.DTOs;

public class CreateUserRequest
{
    public required string FullName { get; set; }
    public required string Username { get; set; }
    public required string Email { get; set; }
    public required string PhoneNumber { get; set; }
    public required string Password { get; set; }
    public UserRole Role { get; set; } = UserRole.Receptionist;
}

public class UpdateUserRequest
{
    public required string FullName { get; set; }
    public required string Email { get; set; }
    public required string PhoneNumber { get; set; }
    public UserRole Role { get; set; }
    public string? NewPassword { get; set; }
}

public class UserListItemDto
{
    public Guid Id { get; set; }
    public required string FullName { get; set; }
    public required string Username { get; set; }
    public required string Email { get; set; }
    public required string PhoneNumber { get; set; }
    public required string Role { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class FinancialReportDto
{
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public decimal TotalRevenueUsd { get; set; }
    public decimal TotalRevenueVes { get; set; }
    public int TotalBookingsCompleted { get; set; }
    public int TotalPaymentsCount { get; set; }
    public List<PaymentSummaryItemDto> RecentPayments { get; set; } = new();
    public List<RevenueByMethodDto> RevenueByPaymentMethod { get; set; } = new();
}

public class PaymentSummaryItemDto
{
    public Guid Id { get; set; }
    public string BookingCode { get; set; } = string.Empty;
    public string GuestName { get; set; } = string.Empty;
    public decimal AmountUsd { get; set; }
    public decimal AmountVes { get; set; }
    public string Method { get; set; } = string.Empty;
    public string ReferenceNumber { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class RevenueByMethodDto
{
    public string Method { get; set; } = string.Empty;
    public decimal TotalUsd { get; set; }
    public int TransactionsCount { get; set; }
}

public class OccupancyReportDto
{
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public double AverageOccupancyRate { get; set; }
    public int TotalRoomsAvailable { get; set; }
    public int TotalNightsSold { get; set; }
    public List<RoomOccupancyItemDto> RoomBreakdown { get; set; } = new();
}

public class RoomOccupancyItemDto
{
    public string RoomNumber { get; set; } = string.Empty;
    public string RoomTitle { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public int NightsSold { get; set; }
    public decimal RevenueGeneratedUsd { get; set; }
}
