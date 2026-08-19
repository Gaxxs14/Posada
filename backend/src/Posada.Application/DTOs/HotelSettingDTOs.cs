namespace Posada.Application.DTOs;

public record HotelSettingDto(
    int Id,
    string HotelName,
    string Description,
    string Address,
    string Phone,
    string Email,
    decimal UsdExchangeRateBcv,
    string CheckInTime,
    string CheckOutTime,
    DateTime UsdRateUpdatedAt
);

public record UpdateHotelSettingRequest(
    string HotelName,
    string Description,
    string Address,
    string Phone,
    string Email,
    decimal UsdExchangeRateBcv,
    string CheckInTime,
    string CheckOutTime
);
