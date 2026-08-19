using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Domain.Entities;
using Posada.Domain.Enums;

namespace Posada.Application.Interfaces;

public interface IJwtTokenGenerator
{
    string GenerateToken(User user, out DateTime expiresAt);
}

public interface IAuthService
{
    Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request);
    Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request);
    Task<ApiResponse<UserProfileDto>> GetProfileAsync(Guid userId);
    Task<ApiResponse<bool>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request);
}

public interface IRoomService
{
    Task<ApiResponse<List<RoomDto>>> GetAllRoomsAsync(RoomStatus? status = null, RoomType? type = null);
    Task<ApiResponse<RoomDto>> GetRoomByIdAsync(Guid id);
    Task<ApiResponse<RoomDto>> CreateRoomAsync(CreateRoomRequest request);
    Task<ApiResponse<RoomDto>> UpdateRoomAsync(Guid id, UpdateRoomRequest request);
    Task<ApiResponse<bool>> UpdateRoomStatusAsync(Guid id, RoomStatus status);
    Task<ApiResponse<bool>> DeleteRoomAsync(Guid id);
}

public interface IBookingService
{
    Task<ApiResponse<BookingQuoteResponse>> GetQuoteAsync(BookingQuoteRequest request);
    Task<ApiResponse<BookingDto>> CreateBookingAsync(Guid guestId, CreateBookingRequest request);
    Task<ApiResponse<List<BookingDto>>> GetUserBookingsAsync(Guid guestId);
    Task<ApiResponse<List<BookingDto>>> GetAllBookingsAsync(BookingStatus? status = null, DateTime? date = null);
    Task<ApiResponse<BookingDto>> GetBookingByCodeAsync(string bookingCode);
    Task<ApiResponse<BookingDto>> GetBookingByIdAsync(Guid id);
    Task<ApiResponse<BookingDto>> UpdateBookingStatusAsync(Guid id, UpdateBookingStatusRequest request, Guid currentUserId);
    Task<ApiResponse<BookingDto>> CheckInAsync(Guid bookingId, Guid receptionistId);
    Task<ApiResponse<BookingDto>> CheckOutAsync(Guid bookingId, Guid receptionistId);
    Task<ApiResponse<PaymentDto>> AddPaymentAsync(Guid bookingId, ProcessPaymentRequest request, Guid currentUserId);
    Task<ApiResponse<ExtraChargeDto>> AddExtraChargeAsync(Guid bookingId, AddExtraChargeRequest request);
}

public interface IDashboardService
{
    Task<ApiResponse<DashboardStatsDto>> GetDashboardStatsAsync();
}

public interface IHotelSettingService
{
    Task<ApiResponse<HotelSettingDto>> GetSettingsAsync();
    Task<ApiResponse<HotelSettingDto>> UpdateSettingsAsync(UpdateHotelSettingRequest request);
    Task<ApiResponse<bool>> UpdateExchangeRateAsync(decimal newRate);
}

public interface IExperienceService
{
    Task<ApiResponse<List<ExperienceDto>>> GetAllAsync();
    Task<ApiResponse<ExperienceDto>> CreateAsync(CreateExperienceRequest request);
    Task<ApiResponse<bool>> DeleteAsync(Guid id);
}

public interface IReviewService
{
    Task<ApiResponse<List<ReviewDto>>> GetRoomReviewsAsync(Guid roomId);
    Task<ApiResponse<ReviewDto>> AddReviewAsync(Guid guestId, CreateReviewRequest request);
}

public interface IAiConciergeService
{
    Task<ApiResponse<AiConciergeResponse>> AskConciergeAsync(AiConciergeRequest request);
}
