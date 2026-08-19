using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;

namespace Posada.Infrastructure.Authentication;

public class JwtTokenGenerator : IJwtTokenGenerator
{
    private readonly IConfiguration _config;

    public JwtTokenGenerator(IConfiguration config)
    {
        _config = config;
    }

    public string GenerateToken(User user, out DateTime expiresAt)
    {
        var secretKey = _config["Jwt:Key"] ?? "PosadaSuperSecretKey2026_UltraSecureKeyForHotelSystemProd_!";
        var issuer = _config["Jwt:Issuer"] ?? "PosadaServer";
        var audience = _config["Jwt:Audience"] ?? "PosadaClients";
        var expiryDays = int.TryParse(_config["Jwt:ExpiryDays"], out var days) ? days : 7;

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        expiresAt = DateTime.UtcNow.AddDays(expiryDays);

        var roleStr = user.Role.ToString();

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(ClaimTypes.Email, user.Email),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new(ClaimTypes.Name, user.FullName),
            new(JwtRegisteredClaimNames.Name, user.FullName),
            new("username", user.Username),
            new(ClaimTypes.Role, roleStr),
            new("role", roleStr),
            new("Role", roleStr)
        };

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = expiresAt,
            Issuer = issuer,
            Audience = audience,
            SigningCredentials = credentials
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);

        return tokenHandler.WriteToken(token);
    }
}
