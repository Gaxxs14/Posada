using Posada.Domain.Enums;

namespace Posada.Application.DTOs;

public record BookingQuoteRequest(
    Guid RoomId,
    DateTime CheckInDate,
    DateTime CheckOutDate,
    int GuestsCount
);

public record BookingQuoteResponse(
    Guid RoomId,
    string RoomNumber,
    string RoomTitle,
    DateTime CheckInDate,
    DateTime CheckOutDate,
    int TotalNights,
    decimal PricePerNightUsd,
    decimal TotalAmountUsd,
    decimal CurrentExchangeRateBcv,
    decimal TotalAmountVes,
    bool IsAvailable
);

public record CreateBookingRequest(
    Guid RoomId,
    DateTime CheckInDate,
    DateTime CheckOutDate,
    int GuestsCount,
    string? SpecialRequests,
    PaymentMethod? InitialPaymentMethod,
    string? PaymentReference
);

public record BookingDto(
    Guid Id,
    string BookingCode,
    Guid GuestId,
    string GuestName,
    string GuestEmail,
    string GuestPhone,
    Guid RoomId,
    string RoomNumber,
    string RoomTitle,
    RoomType RoomType,
    DateTime CheckInDate,
    DateTime CheckOutDate,
    int TotalNights,
    int GuestsCount,
    decimal PricePerNightUsd,
    decimal TotalAmountUsd,
    decimal ExchangeRateUsed,
    decimal TotalAmountVes,
    BookingStatus Status,
    string? SpecialRequests,
    string? AdminNotes,
    DateTime CreatedAt,
    DateTime? CheckedInAt,
    DateTime? CheckedOutAt,
    List<PaymentDto> Payments,
    List<ExtraChargeDto> ExtraCharges,
    decimal TotalPaidUsd,
    decimal RemainingBalanceUsd
);

public record PaymentDto(
    Guid Id,
    Guid BookingId,
    decimal AmountUsd,
    decimal AmountVes,
    decimal ExchangeRate,
    PaymentMethod Method,
    string ReferenceNumber,
    string? ReceiptUrl,
    PaymentStatus Status,
    DateTime CreatedAt
);

public record ProcessPaymentRequest(
    decimal AmountUsd,
    PaymentMethod Method,
    string ReferenceNumber,
    string? ReceiptUrl
);

public record ExtraChargeDto(
    Guid Id,
    Guid BookingId,
    string Description,
    decimal AmountUsd,
    int Quantity,
    decimal TotalUsd,
    DateTime CreatedAt
);

public record AddExtraChargeRequest(
    string Description,
    decimal AmountUsd,
    int Quantity
);

public record UpdateBookingStatusRequest(
    BookingStatus Status,
    string? AdminNotes
);
