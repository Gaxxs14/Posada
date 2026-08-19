using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class HotelSettingService : IHotelSettingService
{
    private readonly AppDbContext _context;

    public HotelSettingService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<HotelSettingDto>> GetSettingsAsync()
    {
        var settings = await _context.HotelSettings.FirstOrDefaultAsync();
        if (settings == null)
        {
            settings = new HotelSetting();
            _context.HotelSettings.Add(settings);
            await _context.SaveChangesAsync();
        }

        var dto = new HotelSettingDto(
            settings.Id,
            settings.HotelName,
            settings.Description,
            settings.Address,
            settings.Phone,
            settings.Email,
            settings.UsdExchangeRateBcv,
            settings.CheckInTime,
            settings.CheckOutTime,
            settings.UsdRateUpdatedAt
        );

        return ApiResponse<HotelSettingDto>.Ok(dto);
    }

    public async Task<ApiResponse<HotelSettingDto>> UpdateSettingsAsync(UpdateHotelSettingRequest request)
    {
        var settings = await _context.HotelSettings.FirstOrDefaultAsync();
        if (settings == null)
        {
            settings = new HotelSetting();
            _context.HotelSettings.Add(settings);
        }

        settings.HotelName = request.HotelName.Trim();
        settings.Description = request.Description.Trim();
        settings.Address = request.Address.Trim();
        settings.Phone = request.Phone.Trim();
        settings.Email = request.Email.Trim();
        settings.CheckInTime = request.CheckInTime;
        settings.CheckOutTime = request.CheckOutTime;

        if (settings.UsdExchangeRateBcv != request.UsdExchangeRateBcv)
        {
            settings.UsdExchangeRateBcv = request.UsdExchangeRateBcv;
            settings.UsdRateUpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
        return await GetSettingsAsync();
    }

    public async Task<ApiResponse<bool>> UpdateExchangeRateAsync(decimal newRate)
    {
        if (newRate <= 0)
        {
            return ApiResponse<bool>.Fail("La tasa de cambio debe ser un valor mayor a cero.");
        }

        var settings = await _context.HotelSettings.FirstOrDefaultAsync();
        if (settings == null)
        {
            settings = new HotelSetting();
            _context.HotelSettings.Add(settings);
        }

        settings.UsdExchangeRateBcv = newRate;
        settings.UsdRateUpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true, "Tasa de cambio actualizada con éxito.");
    }
}
