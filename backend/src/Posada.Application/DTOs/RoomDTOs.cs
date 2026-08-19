using Posada.Domain.Enums;

namespace Posada.Application.DTOs;

public record RoomDto(
    Guid Id,
    string RoomNumber,
    string Title,
    string Description,
    RoomType Type,
    decimal PricePerNightUsd,
    int Capacity,
    List<string> Amenities,
    List<string> ImageUrls,
    RoomStatus Status,
    int Floor,
    bool IsActive
);

public record CreateRoomRequest(
    string RoomNumber,
    string Title,
    string Description,
    RoomType Type,
    decimal PricePerNightUsd,
    int Capacity,
    List<string> Amenities,
    List<string> ImageUrls,
    int Floor
);

public record UpdateRoomRequest(
    string Title,
    string Description,
    RoomType Type,
    decimal PricePerNightUsd,
    int Capacity,
    List<string> Amenities,
    List<string> ImageUrls,
    RoomStatus Status,
    int Floor,
    bool IsActive
);

public record UpdateRoomStatusRequest(
    RoomStatus Status
);
