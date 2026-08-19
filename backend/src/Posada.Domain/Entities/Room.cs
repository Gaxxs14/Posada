using Posada.Domain.Enums;

namespace Posada.Domain.Entities;

public class Room
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string RoomNumber { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public RoomType Type { get; set; } = RoomType.Double;
    public decimal PricePerNightUsd { get; set; }
    public int Capacity { get; set; } = 2;
    public string AmenitiesJson { get; set; } = "[]"; // WiFi, A/C, TV, MiniBar, etc.
    public string ImageUrlsJson { get; set; } = "[]";
    public RoomStatus Status { get; set; } = RoomStatus.Available;
    public int Floor { get; set; } = 1;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
