using Posada.Domain.Enums;

namespace Posada.Domain.Entities;

public class Payment
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid BookingId { get; set; }
    public Booking Booking { get; set; } = null!;

    public decimal AmountUsd { get; set; }
    public decimal AmountVes { get; set; }
    public decimal ExchangeRate { get; set; }
    public PaymentMethod Method { get; set; } = PaymentMethod.MobilePay;
    public string ReferenceNumber { get; set; } = string.Empty;
    public string? ReceiptUrl { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Pending;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public Guid? ApprovedByUserId { get; set; }
    public DateTime? ProcessedAt { get; set; }
}
