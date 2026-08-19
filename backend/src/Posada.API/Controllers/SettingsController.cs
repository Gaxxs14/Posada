using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;

namespace Posada.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SettingsController : ControllerBase
{
    private readonly IHotelSettingService _settingService;

    public SettingsController(IHotelSettingService settingService)
    {
        _settingService = settingService;
    }

    [HttpGet]
    public async Task<IActionResult> GetSettings()
    {
        var result = await _settingService.GetSettingsAsync();
        return Ok(result);
    }

    [Authorize]
    [HttpPut]
    public async Task<IActionResult> UpdateSettings([FromBody] UpdateHotelSettingRequest request)
    {
        var result = await _settingService.UpdateSettingsAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize]
    [HttpPatch("exchange-rate")]
    public async Task<IActionResult> UpdateExchangeRate([FromBody] decimal newRate)
    {
        var result = await _settingService.UpdateExchangeRateAsync(newRate);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
