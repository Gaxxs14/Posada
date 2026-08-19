using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Enums;

namespace Posada.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RoomsController : ControllerBase
{
    private readonly IRoomService _roomService;

    public RoomsController(IRoomService roomService)
    {
        _roomService = roomService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] RoomStatus? status, [FromQuery] RoomType? type)
    {
        var result = await _roomService.GetAllRoomsAsync(status, type);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _roomService.GetRoomByIdAsync(id);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [Authorize(Roles = "Admin,Receptionist")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateRoomRequest request)
    {
        var result = await _roomService.CreateRoomAsync(request);
        return result.Success ? CreatedAtAction(nameof(GetById), new { id = result.Data!.Id }, result) : BadRequest(result);
    }

    [Authorize(Roles = "Admin,Receptionist")]
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateRoomRequest request)
    {
        var result = await _roomService.UpdateRoomAsync(id, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize(Roles = "Admin,Receptionist,Housekeeping")]
    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateRoomStatusRequest request)
    {
        var result = await _roomService.UpdateRoomStatusAsync(id, request.Status);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var result = await _roomService.DeleteRoomAsync(id);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
