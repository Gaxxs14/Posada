using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;

namespace Posada.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ExperiencesController : ControllerBase
{
    private readonly IExperienceService _experienceService;

    public ExperiencesController(IExperienceService experienceService)
    {
        _experienceService = experienceService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await _experienceService.GetAllAsync();
        return Ok(result);
    }

    [Authorize(Roles = "Admin,Receptionist")]
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateExperienceRequest request)
    {
        var result = await _experienceService.CreateAsync(request);
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var result = await _experienceService.DeleteAsync(id);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}

[ApiController]
[Route("api/[controller]")]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet("room/{roomId:guid}")]
    public async Task<IActionResult> GetRoomReviews(Guid roomId)
    {
        var result = await _reviewService.GetRoomReviewsAsync(roomId);
        return Ok(result);
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> AddReview([FromBody] CreateReviewRequest request)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        if (!Guid.TryParse(userIdString, out var guestId)) return Unauthorized();

        var result = await _reviewService.AddReviewAsync(guestId, request);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}

[ApiController]
[Route("api/[controller]")]
public class AiConciergeController : ControllerBase
{
    private readonly IAiConciergeService _conciergeService;

    public AiConciergeController(IAiConciergeService conciergeService)
    {
        _conciergeService = conciergeService;
    }

    [HttpPost("ask")]
    public async Task<IActionResult> Ask([FromBody] AiConciergeRequest request)
    {
        var result = await _conciergeService.AskConciergeAsync(request);
        return Ok(result);
    }
}
