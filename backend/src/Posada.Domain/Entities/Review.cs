namespace Posada.Domain.Entities;

public class Review
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid RoomId { get; set; }
    public Room Room { get; set; } = null!;

    public Guid GuestId { get; set; }
    public User Guest { get; set; } = null!;

    public int Rating { get; set; } = 5; // 1 to 5
    public string Comment { get; set; } = string.Empty;
    public int CleanlinessRating { get; set; } = 5;
    public int ServiceRating { get; set; } = 5;
    public int LocationRating { get; set; } = 5;

    public string? AdminResponse { get; set; }
    public DateTime? AdminRespondedAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
