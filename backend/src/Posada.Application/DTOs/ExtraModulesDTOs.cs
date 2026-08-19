namespace Posada.Application.DTOs;

// Reviews
public record CreateReviewRequest(
    Guid RoomId,
    int Rating,
    string Comment,
    int CleanlinessRating,
    int ServiceRating,
    int LocationRating
);

public record ReviewDto(
    Guid Id,
    Guid RoomId,
    string RoomNumber,
    string GuestName,
    int Rating,
    string Comment,
    int CleanlinessRating,
    int ServiceRating,
    int LocationRating,
    string? AdminResponse,
    DateTime CreatedAt
);

// Experiences & Tours
public record ExperienceDto(
    Guid Id,
    string Title,
    string Description,
    decimal PriceUsd,
    string Duration,
    string Category,
    string ImageUrl,
    bool IncludesTransport
);

public record CreateExperienceRequest(
    string Title,
    string Description,
    decimal PriceUsd,
    string Duration,
    string Category,
    string ImageUrl,
    bool IncludesTransport
);

// Promo Codes
public record ValidatePromoRequest(string Code, decimal TotalAmountUsd, int TotalNights);

public record PromoValidationResponse(
    bool IsValid,
    string Message,
    decimal DiscountPercentage,
    decimal DiscountAmountUsd,
    decimal FinalTotalUsd
);

// AI Concierge
public record AiConciergeMessage(string Sender, string Text, DateTime Timestamp);
public record AiConciergeRequest(string UserMessage, List<AiConciergeMessage>? ConversationHistory);
public record AiConciergeResponse(string ReplyText, List<string>? SuggestedActions);
