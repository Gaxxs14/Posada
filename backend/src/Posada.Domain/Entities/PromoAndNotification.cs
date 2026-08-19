namespace Posada.Domain.Entities;

public class PromoCode
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Code { get; set; } = string.Empty; // e.g. "PLAYA2026", "BIENVENIDO10"
    public decimal DiscountPercentage { get; set; } = 10.0m;
    public decimal? MaxDiscountUsd { get; set; }
    public DateTime ValidUntil { get; set; } = DateTime.UtcNow.AddMonths(3);
    public int MinNights { get; set; } = 1;
    public bool IsActive { get; set; } = true;
}

public class NotificationItem
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Type { get; set; } = "Booking"; // Booking, Payment, Promo, System
    public bool IsRead { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
