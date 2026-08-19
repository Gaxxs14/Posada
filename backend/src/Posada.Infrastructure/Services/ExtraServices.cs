using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class ExperienceService : IExperienceService
{
    private readonly AppDbContext _context;

    public ExperienceService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<ExperienceDto>>> GetAllAsync()
    {
        var items = await _context.Experiences
            .Where(e => e.IsActive)
            .OrderBy(e => e.Category)
            .ToListAsync();

        var dtos = items.Select(e => new ExperienceDto(
            e.Id,
            e.Title,
            e.Description,
            e.PriceUsd,
            e.Duration,
            e.Category,
            e.ImageUrl,
            e.IncludesTransport
        )).ToList();

        return ApiResponse<List<ExperienceDto>>.Ok(dtos);
    }

    public async Task<ApiResponse<ExperienceDto>> CreateAsync(CreateExperienceRequest request)
    {
        var exp = new Experience
        {
            Id = Guid.NewGuid(),
            Title = request.Title.Trim(),
            Description = request.Description.Trim(),
            PriceUsd = request.PriceUsd,
            Duration = request.Duration.Trim(),
            Category = request.Category.Trim(),
            ImageUrl = request.ImageUrl.Trim(),
            IncludesTransport = request.IncludesTransport,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Experiences.Add(exp);
        await _context.SaveChangesAsync();

        var dto = new ExperienceDto(
            exp.Id,
            exp.Title,
            exp.Description,
            exp.PriceUsd,
            exp.Duration,
            exp.Category,
            exp.ImageUrl,
            exp.IncludesTransport
        );

        return ApiResponse<ExperienceDto>.Ok(dto, "Experiencia turística creada.");
    }

    public async Task<ApiResponse<bool>> DeleteAsync(Guid id)
    {
        var exp = await _context.Experiences.FindAsync(id);
        if (exp == null) return ApiResponse<bool>.Fail("No encontrado");

        _context.Experiences.Remove(exp);
        await _context.SaveChangesAsync();
        return ApiResponse<bool>.Ok(true, "Eliminado exitosamente.");
    }
}

public class ReviewService : IReviewService
{
    private readonly AppDbContext _context;

    public ReviewService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<List<ReviewDto>>> GetRoomReviewsAsync(Guid roomId)
    {
        var reviews = await _context.Reviews
            .Include(r => r.Guest)
            .Include(r => r.Room)
            .Where(r => r.RoomId == roomId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        var dtos = reviews.Select(r => new ReviewDto(
            r.Id,
            r.RoomId,
            r.Room.RoomNumber,
            r.Guest.FullName,
            r.Rating,
            r.Comment,
            r.CleanlinessRating,
            r.ServiceRating,
            r.LocationRating,
            r.AdminResponse,
            r.CreatedAt
        )).ToList();

        return ApiResponse<List<ReviewDto>>.Ok(dtos);
    }

    public async Task<ApiResponse<ReviewDto>> AddReviewAsync(Guid guestId, CreateReviewRequest request)
    {
        var room = await _context.Rooms.FindAsync(request.RoomId);
        if (room == null) return ApiResponse<ReviewDto>.Fail("Habitación no encontrada");

        var guest = await _context.Users.FindAsync(guestId);
        if (guest == null) return ApiResponse<ReviewDto>.Fail("Usuario no encontrado");

        var review = new Review
        {
            Id = Guid.NewGuid(),
            RoomId = request.RoomId,
            GuestId = guestId,
            Rating = Math.Clamp(request.Rating, 1, 5),
            Comment = request.Comment.Trim(),
            CleanlinessRating = Math.Clamp(request.CleanlinessRating, 1, 5),
            ServiceRating = Math.Clamp(request.ServiceRating, 1, 5),
            LocationRating = Math.Clamp(request.LocationRating, 1, 5),
            CreatedAt = DateTime.UtcNow
        };

        _context.Reviews.Add(review);
        await _context.SaveChangesAsync();

        var dto = new ReviewDto(
            review.Id,
            review.RoomId,
            room.RoomNumber,
            guest.FullName,
            review.Rating,
            review.Comment,
            review.CleanlinessRating,
            review.ServiceRating,
            review.LocationRating,
            null,
            review.CreatedAt
        );

        return ApiResponse<ReviewDto>.Ok(dto, "Reseña publicada con éxito.");
    }
}

public class AiConciergeService : IAiConciergeService
{
    private readonly AppDbContext _context;

    public AiConciergeService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<ApiResponse<AiConciergeResponse>> AskConciergeAsync(AiConciergeRequest request)
    {
        var prompt = request.UserMessage.ToLower().Trim();
        var settings = await _context.HotelSettings.FirstOrDefaultAsync() ?? new HotelSetting();
        var rooms = await _context.Rooms.Where(r => r.IsActive).ToListAsync();

        string reply;
        List<string> suggestions = new();

        if (prompt.Contains("playa") || prompt.Contains("mar") || prompt.Contains("cayo") || prompt.Contains("turismo"))
        {
            reply = "🌊 **Playas y Paseos Recomendados:**\n" +
                    "Nuestra posada está a solo 3 minutos caminando de Playa Grande. Además, desde nuestro muelle privado coordinamos tours en lancha a los mejores cayos y arrecifes de coral. ¡Pregunta en recepción por los paseos en catamarán!";
            suggestions.Add("Ver Tours y Experiencias");
            suggestions.Add("Consultar precio de paseo en lancha");
        }
        else if (prompt.Contains("desayuno") || prompt.Contains("comida") || prompt.Contains("restaurante") || prompt.Contains("hora"))
        {
            reply = "☕ **Gastronomía y Horarios:**\n" +
                    "El desayuno tipo buffet criollo e internacional se sirve diariamente de **7:30 AM a 10:30 AM** en la terraza con vista al mar. También contamos con servicio a la habitación para café y refrigerios.";
            suggestions.Add("Ver Menú de Desayunos");
            suggestions.Add("¿El desayuno está incluido?");
        }
        else if (prompt.Contains("check-in") || prompt.Contains("checkin") || prompt.Contains("checkout") || prompt.Contains("entrada") || prompt.Contains("salida"))
        {
            reply = $"🕒 **Horarios de Estadía:**\n" +
                    $"• **Check-In:** a partir de las {settings.CheckInTime} hrs.\n" +
                    $"• **Check-Out:** hasta las {settings.CheckOutTime} hrs.\n" +
                    "Si llegas antes, puedes resguardar tu equipaje en recepción y disfrutar de las instalaciones y la piscina.";
            suggestions.Add("¿Puedo hacer Check-In temprano?");
            suggestions.Add("Ver mis reservaciones");
        }
        else if (prompt.Contains("precio") || prompt.Contains("tarifa") || prompt.Contains("dolar") || prompt.Contains("bcv") || prompt.Contains("tasa") || prompt.Contains("bolivar"))
        {
            var minPrice = rooms.Any() ? rooms.Min(r => r.PricePerNightUsd) : 35;
            reply = $"💵 **Tarifas y Monedas:**\n" +
                    $"Nuestras habitaciones van desde **${minPrice} USD** por noche. Aceptamos pagos en Dólares en efectivo, Zelle, Pago Móvil (a la tasa oficial BCV de **{settings.UsdExchangeRateBcv:N2} Bs./USD**) y tarjetas de débito/crédito.";
            suggestions.Add("Ver catálogo de habitaciones");
            suggestions.Add("Cotizar estadía");
        }
        else if (prompt.Contains("wifi") || prompt.Contains("internet") || prompt.Contains("clave"))
        {
            reply = "📶 **Conectividad:**\n" +
                    "Contamos con fibra óptica de alta velocidad (100 Mbps) con cobertura en todas las habitaciones, terraza y área de piscina. La red es `PosadaSolMar_Huespedes` y la clave se entrega al realizar el Check-in.";
            suggestions.Add("¿Tienen planta eléctrica?");
        }
        else
        {
            reply = $"¡Hola! Soy tu **Asistente Virtual de {settings.HotelName}** 🏖️.\n" +
                    "Estoy aquí para ayudarte las 24 horas con información sobre habitaciones disponibles, horarios, tours a los cayos, tasa de cambio y servicios. ¿En qué te puedo asesorar hoy?";
            suggestions.Add("Ver habitaciones");
            suggestions.Add("¿Cuáles son los horarios de check-in?");
            suggestions.Add("Recomiéndame un tour en lancha");
        }

        var response = new AiConciergeResponse(reply, suggestions);
        return ApiResponse<AiConciergeResponse>.Ok(response);
    }
}
