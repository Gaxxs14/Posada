namespace Posada.Domain.Entities;

public class Experience
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Title { get; set; } = string.Empty; // e.g. "Paseo en Yate a Cayo Sombrero", "Cena Romántica en la Playa"
    public string Description { get; set; } = string.Empty;
    public decimal PriceUsd { get; set; }
    public string Duration { get; set; } = "4 horas";
    public string Category { get; set; } = "Tour"; // Tour, Gastronomía, Bienestar, Transporte
    public string ImageUrl { get; set; } = string.Empty;
    public bool IncludesTransport { get; set; } = true;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
