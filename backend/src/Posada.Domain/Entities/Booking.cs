using Posada.Domain.Enums;

namespace Posada.Domain.Entities;

public class Booking
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string BookingCode { get; set; } = string.Empty; // e.g. "POS-2026-A1B2"
    
    public Guid GuestId { get; set; }
    public User Guest { get; set; } = null!;

    public Guid RoomId { get; set; }
    public Room Room { get; set; } = null!;

    public DateTime CheckInDate { get; set; }
    public DateTime CheckOutDate { get; set; }
    public int TotalNights { get; set; }
    public int GuestsCount { get; set; } = 1;

    public decimal PricePerNightUsd { get; set; }
    public decimal TotalAmountUsd { get; set; }
    public decimal ExchangeRateUsed { get; set; } // e.g. BCV rate at booking moment

    public BookingStatus Status { get; set; } = BookingStatus.Pending;
    public string? SpecialRequests { get; set; }
    public string? AdminNotes { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? CheckedInAt { get; set; }
    public DateTime? CheckedOutAt { get; set; }

    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public ICollection<ExtraCharge> ExtraCharges { get; set; } = new List<ExtraCharge>();
}
