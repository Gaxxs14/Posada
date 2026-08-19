namespace Posada.Domain.Entities;

public class ExtraCharge
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid BookingId { get; set; }
    public Booking Booking { get; set; } = null!;

    public string Description { get; set; } = string.Empty; // e.g. "Desayuno Americano", "Bebidas Minibar", "Lavandería"
    public decimal AmountUsd { get; set; }
    public int Quantity { get; set; } = 1;
    public decimal TotalUsd => AmountUsd * Quantity;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
