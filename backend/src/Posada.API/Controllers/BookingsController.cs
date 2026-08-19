using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Enums;

namespace Posada.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _bookingService;

    public BookingsController(IBookingService bookingService)
    {
        _bookingService = bookingService;
    }

    [HttpPost("quote")]
    public async Task<IActionResult> GetQuote([FromBody] BookingQuoteRequest request)
    {
        var result = await _bookingService.GetQuoteAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBookingRequest request)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        if (!Guid.TryParse(userIdString, out var guestId))
        {
            return Unauthorized();
        }

        var result = await _bookingService.CreateBookingAsync(guestId, request);
        return result.Success ? CreatedAtAction(nameof(GetById), new { id = result.Data!.Id }, result) : BadRequest(result);
    }

    [Authorize]
    [HttpGet("my-bookings")]
    public async Task<IActionResult> GetMyBookings()
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        if (!Guid.TryParse(userIdString, out var guestId))
        {
            return Unauthorized();
        }

        var result = await _bookingService.GetUserBookingsAsync(guestId);
        return Ok(result);
    }

    [Authorize]
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] BookingStatus? status, [FromQuery] DateTime? date)
    {
        var result = await _bookingService.GetAllBookingsAsync(status, date);
        return Ok(result);
    }

    [HttpGet("code/{code}")]
    public async Task<IActionResult> GetByCode(string code)
    {
        var result = await _bookingService.GetBookingByCodeAsync(code);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [Authorize]
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await _bookingService.GetBookingByIdAsync(id);
        return result.Success ? Ok(result) : NotFound(result);
    }

    [Authorize]
    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] UpdateBookingStatusRequest request)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        Guid.TryParse(userIdString, out var currentUserId);

        var result = await _bookingService.UpdateBookingStatusAsync(id, request, currentUserId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize]
    [HttpPost("{id:guid}/check-in")]
    public async Task<IActionResult> CheckIn(Guid id)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        Guid.TryParse(userIdString, out var receptionistId);

        var result = await _bookingService.CheckInAsync(id, receptionistId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize]
    [HttpPost("{id:guid}/check-out")]
    public async Task<IActionResult> CheckOut(Guid id)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        Guid.TryParse(userIdString, out var receptionistId);

        var result = await _bookingService.CheckOutAsync(id, receptionistId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize]
    [HttpPost("{id:guid}/payments")]
    public async Task<IActionResult> AddPayment(Guid id, [FromBody] ProcessPaymentRequest request)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        Guid.TryParse(userIdString, out var currentUserId);

        var result = await _bookingService.AddPaymentAsync(id, request, currentUserId);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize]
    [HttpPost("{id:guid}/extra-charges")]
    public async Task<IActionResult> AddExtraCharge(Guid id, [FromBody] AddExtraChargeRequest request)
    {
        var result = await _bookingService.AddExtraChargeAsync(id, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
