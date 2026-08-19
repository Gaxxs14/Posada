using Microsoft.EntityFrameworkCore;
using Posada.Application.Common;
using Posada.Application.DTOs;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;
using Posada.Domain.Enums;
using Posada.Infrastructure.Data;

namespace Posada.Infrastructure.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _context;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;

    public AuthService(AppDbContext context, IJwtTokenGenerator jwtTokenGenerator)
    {
        _context = context;
        _jwtTokenGenerator = jwtTokenGenerator;
    }

    public async Task<ApiResponse<AuthResponse>> LoginAsync(LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Identifier) || string.IsNullOrWhiteSpace(request.Password))
        {
            return ApiResponse<AuthResponse>.Fail("Credenciales incompletas.");
        }

        var normalized = request.Identifier.Trim().ToLower();
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == normalized || u.Username.ToLower() == normalized);

        if (user == null || !user.IsActive)
        {
            return ApiResponse<AuthResponse>.Fail("Usuario o contraseña incorrectos.");
        }

        bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
        if (!isPasswordValid)
        {
            return ApiResponse<AuthResponse>.Fail("Usuario o contraseña incorrectos.");
        }

        var token = _jwtTokenGenerator.GenerateToken(user, out var expiresAt);

        var response = new AuthResponse(
            user.Id,
            user.FullName,
            user.Username,
            user.Email,
            user.PhoneNumber,
            user.Role,
            token,
            expiresAt
        );

        return ApiResponse<AuthResponse>.Ok(response, "Inicio de sesión exitoso.");
    }

    public async Task<ApiResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
    {
        var emailNormalized = request.Email.Trim().ToLower();
        var usernameNormalized = request.Username.Trim().ToLower();

        if (await _context.Users.AnyAsync(u => u.Email.ToLower() == emailNormalized))
        {
            return ApiResponse<AuthResponse>.Fail("El correo electrónico ya se encuentra registrado.");
        }

        if (await _context.Users.AnyAsync(u => u.Username.ToLower() == usernameNormalized))
        {
            return ApiResponse<AuthResponse>.Fail("El nombre de usuario ya se encuentra en uso.");
        }

        var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password, workFactor: 11);

        var user = new User
        {
            Id = Guid.NewGuid(),
            FullName = request.FullName.Trim(),
            Username = request.Username.Trim(),
            Email = emailNormalized,
            PhoneNumber = request.PhoneNumber?.Trim() ?? string.Empty,
            PasswordHash = passwordHash,
            Role = UserRole.Guest,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var token = _jwtTokenGenerator.GenerateToken(user, out var expiresAt);

        var response = new AuthResponse(
            user.Id,
            user.FullName,
            user.Username,
            user.Email,
            user.PhoneNumber,
            user.Role,
            token,
            expiresAt
        );

        return ApiResponse<AuthResponse>.Ok(response, "Registro completado con éxito.");
    }

    public async Task<ApiResponse<UserProfileDto>> GetProfileAsync(Guid userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return ApiResponse<UserProfileDto>.Fail("Usuario no encontrado.");
        }

        var dto = new UserProfileDto(
            user.Id,
            user.FullName,
            user.Username,
            user.Email,
            user.PhoneNumber,
            user.Role,
            user.CreatedAt
        );

        return ApiResponse<UserProfileDto>.Ok(dto);
    }

    public async Task<ApiResponse<bool>> ChangePasswordAsync(Guid userId, ChangePasswordRequest request)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null)
        {
            return ApiResponse<bool>.Fail("Usuario no encontrado.");
        }

        if (!BCrypt.Net.BCrypt.Verify(request.CurrentPassword, user.PasswordHash))
        {
            return ApiResponse<bool>.Fail("La contraseña actual es incorrecta.");
        }

        user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword, workFactor: 11);
        await _context.SaveChangesAsync();

        return ApiResponse<bool>.Ok(true, "Contraseña actualizada exitosamente.");
    }
}
