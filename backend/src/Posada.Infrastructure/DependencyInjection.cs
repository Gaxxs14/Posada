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
        var connectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? configuration["DATABASE_URL"] 
            ?? "Host=localhost;Port=5432;Database=posada_pro;Username=postgres;Password=postgres";

        services.AddDbContext<AppDbContext>(options =>
        {
            options.UseNpgsql(connectionString);
        });

        services.AddScoped<IAppDbContext>(provider => provider.GetRequiredService<AppDbContext>());

        // Services
        services.AddScoped<IJwtTokenGenerator, JwtTokenGenerator>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IRoomService, RoomService>();
        services.AddScoped<IBookingService, BookingService>();
        services.AddScoped<IDashboardService, DashboardService>();
        services.AddScoped<IHotelSettingService, HotelSettingService>();
        services.AddScoped<IExperienceService, ExperienceService>();
        services.AddScoped<IReviewService, ReviewService>();
        services.AddScoped<IAiConciergeService, AiConciergeService>();

        // JWT Authentication
        var secretKey = configuration["Jwt:Key"] ?? "PosadaSuperSecretKey2026_UltraSecureKeyForHotelSystemProd_!";
        var issuer = configuration["Jwt:Issuer"] ?? "PosadaServer";
        var audience = configuration["Jwt:Audience"] ?? "PosadaClients";

        services.AddAuthentication(options =>
        {
            options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
        })
        .AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = issuer,
                ValidAudience = audience,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
            };
        });

        return services;
    }
}
