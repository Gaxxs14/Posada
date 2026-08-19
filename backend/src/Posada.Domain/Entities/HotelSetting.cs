namespace Posada.Domain.Entities;

public class HotelSetting
{
    public int Id { get; set; } = 1;
    public string HotelName { get; set; } = "Posada Turística Sol y Mar";
    public string Description { get; set; } = "Tu refugio ideal frente al mar.";
    public string Address { get; set; } = "Av. Principal, Sector Playa, Venezuela";
    public string Phone { get; set; } = "+58 424-8170076";
    public string Email { get; set; } = "contacto@posadasolmar.com";
    public decimal UsdExchangeRateBcv { get; set; } = 765.00m;
    public string CheckInTime { get; set; } = "15:00";
    public string CheckOutTime { get; set; } = "11:00";
    public DateTime UsdRateUpdatedAt { get; set; } = DateTime.UtcNow;
}
