using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;
using Posada.Domain.Enums;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class RoomService : IRoomService
{
    private readonly AppDbContext _context;

    public RoomService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<RoomDto>>> GetAllRoomsAsync(RoomStatus? status = null, RoomType? type = null)
    {
        var query = _context.Rooms.AsQueryable();

        if (status.HasValue)
        {
            query = query.Where(r => r.Status == status.Value);
        }

        if (type.HasValue)
        {
            query = query.Where(r => r.Type == type.Value);
        }

        var rooms = await query
            .OrderBy(r => r.Floor)
            .ThenBy(r => r.RoomNumber)
            .ToListAsync();

        var dtos = rooms.Select(MapToDto).ToList();
        return ApiResponse<List<RoomDto>>.Ok(dtos);
    }

    public async Task<ApiResponse<RoomDto>> GetRoomByIdAsync(Guid id)
    {
        var room = await _context.Rooms.FindAsync(id);
        if (room == null)
        {
            return ApiResponse<RoomDto>.Fail("Habitación no encontrada.");
        }

        return ApiResponse<RoomDto>.Ok(MapToDto(room));
    }

    public async Task<ApiResponse<RoomDto>> CreateRoomAsync(CreateRoomRequest request)
    {
        var exists = await _context.Rooms.AnyAsync(r => r.RoomNumber.ToLower() == request.RoomNumber.Trim().ToLower());
        if (exists)
        {
            return ApiResponse<RoomDto>.Fail($"Ya existe una habitación con el número {request.RoomNumber}.");
        }

        var room = new Room
        {
            Id = Guid.NewGuid(),
            RoomNumber = request.RoomNumber.Trim(),
            Title = request.Title.Trim(),
            Description = request.Description.Trim(),
            Type = request.Type,
            PricePerNightUsd = request.PricePerNightUsd,
            Capacity = request.Capacity,
            AmenitiesJson = JsonSerializer.Serialize(request.Amenities ?? new List<string>()),
            ImageUrlsJson = JsonSerializer.Serialize(request.ImageUrls ?? new List<string>()),
            Status = RoomStatus.Available,
            Floor = request.Floor,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Rooms.Add(room);
        await _context.SaveChangesAsync();

        return ApiResponse<RoomDto>.Ok(MapToDto(room), "Habitación creada exitosamente.");
    }

    public async Task<ApiResponse<RoomDto>> UpdateRoomAsync(Guid id, UpdateRoomRequest request)
    {
        var room = await _context.Rooms.FindAsync(id);
        if (room == null)
        {
            return ApiResponse<RoomDto>.Fail("Habitación no encontrada.");
        }

        room.Title = request.Title.Trim();
        room.Description = request.Description.Trim();
        room.Type = request.Type;
        room.PricePerNightUsd = request.PricePerNightUsd;
        room.Capacity = request.Capacity;
        room.AmenitiesJson = JsonSerializer.Serialize(request.Amenities ?? new List<string>());
        room.ImageUrlsJson = JsonSerializer.Serialize(request.ImageUrls ?? new List<string>());
        room.Status = request.Status;
        room.Floor = request.Floor;
        room.IsActive = request.IsActive;

        await _context.SaveChangesAsync();
        return ApiResponse<RoomDto>.Ok(MapToDto(room), "Habitación actualizada exitosamente.");
    }

    public async Task<ApiResponse<bool>> UpdateRoomStatusAsync(Guid id, RoomStatus status)
    {
        var room = await _context.Rooms.FindAsync(id);
        if (room == null)
        {
            return ApiResponse<bool>.Fail("Habitación no encontrada.");
        }

        room.Status = status;
        await _context.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true, "Estado de habitación actualizado.");
    }

    public async Task<ApiResponse<bool>> DeleteRoomAsync(Guid id)
    {
        var room = await _context.Rooms.Include(r => r.Bookings).FirstOrDefaultAsync(r => r.Id == id);
        if (room == null)
        {
            return ApiResponse<bool>.Fail("Habitación no encontrada.");
        }

        if (room.Bookings.Any(b => b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.CheckedIn))
        {
            return ApiResponse<bool>.Fail("No se puede eliminar la habitación porque tiene reservas activas. Puedes desactivarla en su lugar.");
        }

        _context.Rooms.Remove(room);
        await _context.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true, "Habitación eliminada correctamente.");
    }

    private static RoomDto MapToDto(Room r)
    {
        List<string> amenities = new();
        List<string> images = new();

        try { amenities = JsonSerializer.Deserialize<List<string>>(r.AmenitiesJson) ?? new(); } catch { }
        try { images = JsonSerializer.Deserialize<List<string>>(r.ImageUrlsJson) ?? new(); } catch { }

        return new RoomDto(
            r.Id,
            r.RoomNumber,
            r.Title,
            r.Description,
            r.Type,
            r.PricePerNightUsd,
            r.Capacity,
            amenities,
            images,
            r.Status,
            r.Floor,
            r.IsActive
        );
    }
}
