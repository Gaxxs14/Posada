using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Posada.Domain.Entities;
using Posada.Domain.Enums;

namespace Posada.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task SeedDataAsync(AppDbContext context)
    {
        await context.Database.EnsureCreatedAsync();

        // 1. Seed Hotel Settings
        if (!await context.HotelSettings.AnyAsync())
        {
            context.HotelSettings.Add(new HotelSetting
            {
                Id = 1,
                HotelName = "Posada Turística Sol y Mar",
                Description = "Disfruta de la mejor experiencia frente al mar caribe con confort, tranquilidad y servicio de primera categoría.",
                Address = "Boulevard Costero, Sector Playa Grande, Venezuela",
                Phone = "+58 424-8170076",
                Email = "contacto@posadasolmar.com",
                UsdExchangeRateBcv = 765.00m,
                CheckInTime = "14:00",
                CheckOutTime = "11:00",
                UsdRateUpdatedAt = DateTime.UtcNow
            });
            await context.SaveChangesAsync();
        }

        // 2. Seed Users
        User adminUser;
        User receptionistUser;
        User guestUser;

        if (!await context.Users.AnyAsync())
        {
            adminUser = new User
            {
                Id = Guid.NewGuid(),
                FullName = "Gabriel Gallardo (Admin)",
                Username = "admin",
                Email = "admin@posada.com",
                PhoneNumber = "+58 424-8170076",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin12345*", workFactor: 11),
                Role = UserRole.Admin,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            receptionistUser = new User
            {
                Id = Guid.NewGuid(),
                FullName = "Recepcionista Principal",
                Username = "recepcion",
                Email = "recepcion@posada.com",
                PhoneNumber = "+58 412-1234567",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Recepcion123*", workFactor: 11),
                Role = UserRole.Receptionist,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            guestUser = new User
            {
                Id = Guid.NewGuid(),
                FullName = "Julimer Gallardo (Cliente)",
                Username = "julimer",
                Email = "julimer@gmail.com",
                PhoneNumber = "+58 414-9876543",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Cliente123*", workFactor: 11),
                Role = UserRole.Guest,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            context.Users.AddRange(adminUser, receptionistUser, guestUser);
            await context.SaveChangesAsync();
        }
        else
        {
            adminUser = await context.Users.FirstAsync(u => u.Role == UserRole.Admin);
            receptionistUser = await context.Users.FirstOrDefaultAsync(u => u.Role == UserRole.Receptionist) ?? adminUser;
            guestUser = await context.Users.FirstOrDefaultAsync(u => u.Role == UserRole.Guest) ?? adminUser;
        }

        // 3. Seed Rooms
        if (!await context.Rooms.AnyAsync())
        {
            var rooms = new List<Room>
            {
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "101",
                    Title = "Habitación Estándar Matrimonial",
                    Description = "Habitación cómoda equipada con cama Queen, baño privado, aire acondicionado y vista al jardín interno.",
                    Type = RoomType.Double,
                    PricePerNightUsd = 45.00m,
                    Capacity = 2,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "WiFi Alta Velocidad", "Aire Acondicionado", "Smart TV 43\"", "Baño Privado", "Agua Caliente" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800", "https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800" }),
                    Status = RoomStatus.Occupied,
                    Floor = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "102",
                    Title = "Suite Frente al Mar con Balcón",
                    Description = "Espectacular suite con vista directa al mar caribe, cama King size, jacuzzi privado y terraza privada con hamaca.",
                    Type = RoomType.Suite,
                    PricePerNightUsd = 95.00m,
                    Capacity = 2,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Vista al Mar", "Jacuzzi Privado", "WiFi Alta Velocidad", "Aire Acondicionado", "Smart TV 55\"", "Minibar Incluido", "Desayuno Incluido" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800", "https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800" }),
                    Status = RoomStatus.NeedsCleaning,
                    Floor = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "201",
                    Title = "Cabaña Familiar Deluxe",
                    Description = "Espaciosa habitación familiar con dos camas Queen y una individual, sala de estar y pequeña cocina equipada.",
                    Type = RoomType.Family,
                    PricePerNightUsd = 120.00m,
                    Capacity = 5,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Cocina Equipada", "WiFi Alta Velocidad", "Aire Acondicionado Split", "2 Smart TVs", "Nevera Ejecutiva", "Comedor", "Estacionamiento Privado" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=800", "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "202",
                    Title = "Habitación Triple Confort",
                    Description = "Habitación versátil con una cama matrimonial y una cama individual, ideal para grupos pequeños o amigos.",
                    Type = RoomType.Triple,
                    PricePerNightUsd = 65.00m,
                    Capacity = 3,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "WiFi Alta Velocidad", "Aire Acondicionado", "Smart TV 43\"", "Closet Amplio", "Agua Caliente" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "203",
                    Title = "Habitación Individual Ejecutiva",
                    Description = "Habitación acogedora con cama individual, escritorio de trabajo, internet de alta velocidad y café de cortesía.",
                    Type = RoomType.Single,
                    PricePerNightUsd = 35.00m,
                    Capacity = 1,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Escritorio de Trabajo", "WiFi Alta Velocidad", "Aire Acondicionado", "Smart TV", "Cafetera" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };

            context.Rooms.AddRange(rooms);
            await context.SaveChangesAsync();
        }

        // 4. Seed Experiences
        if (!await context.Experiences.AnyAsync())
        {
            var experiences = new List<Experience>
            {
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Tour en Catamarán a Cayo Sombrero",
                    Description = "Día completo de navegación en catamarán con snorkel en arrecifes de coral, frutas tropicales y bebidas incluidas.",
                    PriceUsd = 45.00m,
                    Duration = "6 horas",
                    Category = "Tour",
                    ImageUrl = "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800",
                    IncludesTransport = true,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Cena Romántica Frente al Mar",
                    Description = "Cena privada de 3 tiempos bajo las estrellas con antorchas, botella de vino y sonido de las olas.",
                    PriceUsd = 60.00m,
                    Duration = "3 horas",
                    Category = "Gastronomía",
                    ImageUrl = "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                    IncludesTransport = false,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Sesión de Masajes Relajantes en la Terraza",
                    Description = "Masaje antiestrés de 60 minutos con aceites esenciales aromáticos y vista panorámica al mar caribe.",
                    PriceUsd = 35.00m,
                    Duration = "1 hora",
                    Category = "Bienestar",
                    ImageUrl = "https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800",
                    IncludesTransport = false,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };

            context.Experiences.AddRange(experiences);
            await context.SaveChangesAsync();
        }

        // 5. Seed Bookings & Payments if none exist
        if (!await context.Bookings.AnyAsync())
        {
            var room101 = await context.Rooms.FirstAsync(r => r.RoomNumber == "101");
            var room102 = await context.Rooms.FirstAsync(r => r.RoomNumber == "102");
            var room201 = await context.Rooms.FirstAsync(r => r.RoomNumber == "201");

            var bcv = 765.00m;

            var booking1 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0801",
                GuestId = guestUser.Id,
                RoomId = room101.Id,
                CheckInDate = DateTime.UtcNow.Date.AddDays(-1),
                CheckOutDate = DateTime.UtcNow.Date.AddDays(2),
                TotalNights = 3,
                GuestsCount = 2,
                PricePerNightUsd = 45.00m,
                TotalAmountUsd = 135.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedIn,
                CheckedInAt = DateTime.UtcNow.AddDays(-1),
                CreatedAt = DateTime.UtcNow.AddDays(-5),
                SpecialRequests = "Check-in temprano por favor"
            };

            var payment1 = new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = booking1.Id,
                AmountUsd = 135.00m,
                AmountVes = 135.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.MobilePay,
                ReferenceNumber = "PAGO-MOVIL-984210",
                Status = PaymentStatus.Approved,
                ProcessedAt = DateTime.UtcNow.AddDays(-1),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-5)
            };

            var booking2 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0802",
                GuestId = guestUser.Id,
                RoomId = room201.Id,
                CheckInDate = DateTime.UtcNow.Date.AddDays(1),
                CheckOutDate = DateTime.UtcNow.Date.AddDays(4),
                TotalNights = 3,
                GuestsCount = 4,
                PricePerNightUsd = 120.00m,
                TotalAmountUsd = 360.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.Confirmed,
                CreatedAt = DateTime.UtcNow.AddDays(-2),
                SpecialRequests = "Cuna para bebé"
            };

            var payment2 = new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = booking2.Id,
                AmountUsd = 360.00m,
                AmountVes = 360.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.Zelle,
                ReferenceNumber = "ZELLE-TRX-551920",
                Status = PaymentStatus.Approved,
                ProcessedAt = DateTime.UtcNow.AddDays(-2),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-2)
            };

            var booking3 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0803",
                GuestId = guestUser.Id,
                RoomId = room102.Id,
                CheckInDate = DateTime.UtcNow.Date.AddDays(3),
                CheckOutDate = DateTime.UtcNow.Date.AddDays(5),
                TotalNights = 2,
                GuestsCount = 2,
                PricePerNightUsd = 95.00m,
                TotalAmountUsd = 190.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.Pending,
                CreatedAt = DateTime.UtcNow.AddHours(-3),
                SpecialRequests = "Vista al mar alta"
            };

            context.Bookings.AddRange(booking1, booking2, booking3);
            context.Payments.AddRange(payment1, payment2);

            room101.Status = RoomStatus.Occupied;
            room102.Status = RoomStatus.NeedsCleaning;

            await context.SaveChangesAsync();
        }
    }
}
