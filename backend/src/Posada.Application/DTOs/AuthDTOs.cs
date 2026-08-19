using Posada.Domain.Enums;

namespace Posada.Application.DTOs;

public record LoginRequest(string Identifier, string Password);

public record RegisterRequest(
    string FullName,
    string Username,
    string Email,
    string PhoneNumber,
    string Password
);

public record AuthResponse(
    Guid Id,
    string FullName,
    string Username,
    string Email,
    string PhoneNumber,
    UserRole Role,
    string Token,
    DateTime ExpiresAt
);

public record UserProfileDto(
    Guid Id,
    string FullName,
    string Username,
    string Email,
    string PhoneNumber,
    UserRole Role,
    DateTime CreatedAt
);

public record ChangePasswordRequest(
    string CurrentPassword,
    string NewPassword
);
