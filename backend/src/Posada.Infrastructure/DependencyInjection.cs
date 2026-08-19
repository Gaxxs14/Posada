using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Posada.Application.Interfaces;
using Posada.Infrastructure.Authentication;
using Posada.Infrastructure.Data;
using Posada.Infrastructure.Services;

namespace Posada.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // Database Connection (PostgreSQL or In-Memory fallback)
        var rawConnectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? configuration["DATABASE_URL"] 
            ?? configuration["DefaultConnection"];

        var connectionString = ParsePostgreSqlConnectionString(rawConnectionString);

        if (!string.IsNullOrWhiteSpace(connectionString))
        {
            services.AddDbContext<AppDbContext>(options =>
                options.UseNpgsql(connectionString, b => b.MigrationsAssembly(typeof(AppDbContext).Assembly.FullName)));
        }

        // Domain Services
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IRoomService, RoomService>();
        services.AddScoped<IBookingService, BookingService>();
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddScoped<IHotelSettingService, HotelSettingService>();
        services.AddScoped<IExperienceService, ExperienceService>();
        services.AddScoped<IReviewService, ReviewService>();
        services.AddScoped<IAiConciergeService, AiConciergeService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IReportService, ReportService>();

        // JWT Authentication
        var secretKey = configuration["Jwt:Key"] 
            ?? configuration["Jwt__Key"]
            ?? "PosadaSuperSecretKey2026_UltraSecureKeyForHotelSystemProd_!";
        var issuer = configuration["Jwt:Issuer"] ?? configuration["Jwt__Issuer"] ?? "PosadaServer";
        var audience = configuration["Jwt:Audience"] ?? configuration["Jwt__Audience"] ?? "PosadaClients";

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.RequireHttpsMetadata = false;
            options.SaveToken = true;
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = issuer,
                ValidAudience = audience,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
                RoleClaimType = ClaimTypes.Role,
                NameClaimType = ClaimTypes.NameIdentifier
            };
        });

        return services;
    }

    private static string ParsePostgreSqlConnectionString(string raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return raw;

        raw = raw.Trim();
        if (raw.StartsWith("postgres://", StringComparison.OrdinalIgnoreCase) ||
            raw.StartsWith("postgresql://", StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                var uri = new Uri(raw);
                var userInfo = uri.UserInfo.Split(':');
                var username = userInfo.Length > 0 ? Uri.UnescapeDataString(userInfo[0]) : "";
                var password = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : "";
                var host = uri.Host;
                var port = uri.Port > 0 ? uri.Port : 5432;
                var database = uri.AbsolutePath.TrimStart('/');

                return $"Host={host};Port={port};Database={database};Username={username};Password={password};SSL Mode=Require;Trust Server Certificate=true;";
            }
            catch
            {
                return raw;
            }
        }

        return raw;
    }
}
