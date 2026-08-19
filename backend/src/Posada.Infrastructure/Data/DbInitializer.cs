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

        var bcv = 765.00m;

        // 1. Hotel Settings
        var settings = await context.HotelSettings.FirstOrDefaultAsync();
        if (settings == null)
        {
            context.HotelSettings.Add(new HotelSetting
            {
                Id = 1,
                HotelName = "Posada Turística Sol y Mar",
                Description = "Disfruta de la mejor experiencia frente al mar caribe con confort, tranquilidad, gastronomía costera y atención de primera categoría.",
                Address = "Boulevard Costero, Sector Playa Grande, Falcón / Morrocoy, Venezuela",
                Phone = "+58 424-8170076",
                Email = "contacto@posadasolmar.com",
                UsdExchangeRateBcv = bcv,
                CheckInTime = "15:00",
                CheckOutTime = "12:00",
                UsdRateUpdatedAt = DateTime.UtcNow
            });
            await context.SaveChangesAsync();
        }
        else
        {
            settings.HotelName = "Posada Turística Sol y Mar";
            settings.UsdExchangeRateBcv = bcv;
            settings.UsdRateUpdatedAt = DateTime.UtcNow;
            await context.SaveChangesAsync();
        }

        // 2. Users (Admin, Receptionists, Housekeeping, Real Guests)
        var users = await context.Users.ToListAsync();

        User adminUser = users.FirstOrDefault(u => u.Username == "admin") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Gabriel Gallardo",
            Username = "admin",
            Email = "admin@posada.com",
            PhoneNumber = "+58 424-8170076",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin12345*", workFactor: 11),
            Role = UserRole.Admin,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-6)
        };
        if (!users.Any(u => u.Username == "admin")) context.Users.Add(adminUser);

        User recepcionUser = users.FirstOrDefault(u => u.Username == "recepcion") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Valentina Silva",
            Username = "recepcion",
            Email = "valentina.recepcion@posada.com",
            PhoneNumber = "+58 412-3344556",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Recepcion123*", workFactor: 11),
            Role = UserRole.Receptionist,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-5)
        };
        if (!users.Any(u => u.Username == "recepcion")) context.Users.Add(recepcionUser);

        User recepcion2User = users.FirstOrDefault(u => u.Username == "andres.recepcion") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Andrés Morales",
            Username = "andres.recepcion",
            Email = "andres.recepcion@posada.com",
            PhoneNumber = "+58 424-5566778",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Staff123*", workFactor: 11),
            Role = UserRole.Receptionist,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-4)
        };
        if (!users.Any(u => u.Username == "andres.recepcion")) context.Users.Add(recepcion2User);

        User housekeepingUser = users.FirstOrDefault(u => u.Username == "carlos.limpieza") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Carlos Mendoza (Gobernanta)",
            Username = "carlos.limpieza",
            Email = "carlos.limpieza@posada.com",
            PhoneNumber = "+58 416-7788990",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Staff123*", workFactor: 11),
            Role = UserRole.Housekeeping,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-4)
        };
        if (!users.Any(u => u.Username == "carlos.limpieza")) context.Users.Add(housekeepingUser);

        User guest1 = users.FirstOrDefault(u => u.Username == "julimer") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Julimer Gallardo",
            Username = "julimer",
            Email = "julimer.gallardo@gmail.com",
            PhoneNumber = "+58 414-9876543",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Cliente123*", workFactor: 11),
            Role = UserRole.Guest,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-5)
        };
        if (!users.Any(u => u.Username == "julimer")) context.Users.Add(guest1);

        User guest2 = users.FirstOrDefault(u => u.Username == "roberto.gomez") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Roberto Gómez",
            Username = "roberto.gomez",
            Email = "roberto.gomez@gmail.com",
            PhoneNumber = "+58 414-2233445",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Cliente123*", workFactor: 11),
            Role = UserRole.Guest,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-3)
        };
        if (!users.Any(u => u.Username == "roberto.gomez")) context.Users.Add(guest2);

        User guest3 = users.FirstOrDefault(u => u.Username == "mariana.torres") ?? new User
        {
            Id = Guid.NewGuid(),
            FullName = "Mariana Torres",
            Username = "mariana.torres",
            Email = "mariana.torres@hotmail.com",
            PhoneNumber = "+58 424-1122334",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Cliente123*", workFactor: 11),
            Role = UserRole.Guest,
            IsActive = true,
            CreatedAt = DateTime.UtcNow.AddMonths(-2)
        };
        if (!users.Any(u => u.Username == "mariana.torres")) context.Users.Add(guest3);

        await context.SaveChangesAsync();

        // 3. Rooms (8 Realistic Rooms)
        var existingRooms = await context.Rooms.ToListAsync();
        if (existingRooms.Count < 5)
        {
            context.Rooms.RemoveRange(existingRooms);
            await context.SaveChangesAsync();

            var newRooms = new List<Room>
            {
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "101",
                    Title = "Habitación Estándar Matrimonial",
                    Description = "Habitación acogedora con cama Queen, lencería de 300 hilos, baño privado con ducha española, aire acondicionado split silencioso y vista al patio interno tropical.",
                    Type = RoomType.Double,
                    PricePerNightUsd = 45.00m,
                    Capacity = 2,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "WiFi Fibra Óptica 100Mbps", "Aire Acondicionado", "Smart TV 43\" con Netflix", "Baño Privado", "Agua Caliente", "Secador de Cabello" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800", "https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=800" }),
                    Status = RoomStatus.Occupied,
                    Floor = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "102",
                    Title = "Suite Frente al Mar con Balcón",
                    Description = "Exclusiva suite con vista panorámica frontal al mar, cama King size, jacuzzi privado de hidromasaje en la terraza, hamaca artesanal y frigobar surtido.",
                    Type = RoomType.Suite,
                    PricePerNightUsd = 95.00m,
                    Capacity = 2,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Vista Frontal al Mar", "Jacuzzi de Hidromasaje", "WiFi Fibra Óptica", "Smart TV 55\" 4K", "Minibar de Cortesía", "Desayuno Buffet Incluido", "Cafetera Nespresso" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800", "https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800" }),
                    Status = RoomStatus.NeedsCleaning,
                    Floor = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "103",
                    Title = "Habitación Doble Superior Jardín",
                    Description = "Espaciosa habitación en planta baja con salida directa al jardín de palmeras, dos camas matrimoniales y terraza privada amoblada.",
                    Type = RoomType.Double,
                    PricePerNightUsd = 55.00m,
                    Capacity = 2,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Salida Directa a Jardín", "WiFi Alta Velocidad", "Aire Acondicionado Split", "Smart TV 50\"", "Caja Fuerte", "Nevera Ejecutiva" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "201",
                    Title = "Cabaña Familiar Deluxe",
                    Description = "Amplia cabaña de dos ambientes con cama King y dos camas individuales, comedor, cocina completamente equipada y balcón con hamacas.",
                    Type = RoomType.Family,
                    PricePerNightUsd = 120.00m,
                    Capacity = 5,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Cocina Equipada", "2 Ambientes", "2 Smart TVs 50\"", "Comedor Familiar", "WiFi Fibra Óptica", "Aire Acondicionado en cada ambiente", "Estacionamiento Privado" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=800", "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800" }),
                    Status = RoomStatus.Occupied,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "202",
                    Title = "Habitación Triple Confort Caribe",
                    Description = "Habitación luminosa en segundo piso con cama Queen y cama individual, excelente ventilación cruzada y balcón con vista parcial a la bahía.",
                    Type = RoomType.Triple,
                    PricePerNightUsd = 75.00m,
                    Capacity = 3,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Vista Parcial a la Bahía", "WiFi Alta Velocidad", "Aire Acondicionado", "Smart TV 43\"", "Balcón Privado", "Agua Caliente" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "203",
                    Title = "Habitación Individual Ejecutiva",
                    Description = "Habitación tranquila diseñada para profesionales y viajeros individuales, con escritorio ergonómico, conexión de alta velocidad y café de cortesía.",
                    Type = RoomType.Single,
                    PricePerNightUsd = 35.00m,
                    Capacity = 1,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Escritorio Ergonómico", "WiFi Fibra 100Mbps", "Aire Acondicionado", "Smart TV", "Cafetera con Cápsulas de Cortesía" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "204",
                    Title = "Master Suite Presidencial Panorámica",
                    Description = "Nuestra suite más prestigiosa en el último piso con vista de 180 grados al mar Caribe, jacuzzi exterior, sala lounge y servicio a la habitación preferencial.",
                    Type = RoomType.Suite,
                    PricePerNightUsd = 160.00m,
                    Capacity = 4,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Vista Panorámica 180°", "Jacuzzi Exterior en Terraza", "Sala Lounge Privada", "Cama Super King", "Room Service 24h", "Desayuno a la Carta", "Champagne de Bienvenida" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800", "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    RoomNumber = "205",
                    Title = "Cabaña Tropical Familiar",
                    Description = "Cabaña de estilo rústico playero con vigas de madera noble, cama King y dos literas individuales, perfecta para escapadas con niños.",
                    Type = RoomType.Family,
                    PricePerNightUsd = 110.00m,
                    Capacity = 4,
                    AmenitiesJson = JsonSerializer.Serialize(new[] { "Espacio Familiar", "WiFi Alta Velocidad", "Aire Acondicionado", "Nevera Ejecutiva", "Juegos de Mesa", "Cerca de la Piscina" }),
                    ImageUrlsJson = JsonSerializer.Serialize(new[] { "https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=800" }),
                    Status = RoomStatus.Available,
                    Floor = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                }
            };

            context.Rooms.AddRange(newRooms);
            await context.SaveChangesAsync();
        }

        // 4. Experiences (Authentic Venezuelan Coast Tours)
        var experiences = await context.Experiences.ToListAsync();
        if (experiences.Count < 3)
        {
            context.Experiences.RemoveRange(experiences);
            await context.SaveChangesAsync();

            var newExperiences = new List<Experience>
            {
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Full Day en Catamarán a Cayo Sombrero & Los Juanes",
                    Description = "Navegación de día completo con barra libre nacional, almuerzo marinero en la playa, parada de snorkel en arrecifes vírgenes y fiesta al atardecer en Los Juanes.",
                    PriceUsd = 55.00m,
                    Duration = "8 horas (8:00 AM - 4:30 PM)",
                    Category = "Navegación y Playa",
                    ImageUrl = "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800",
                    IncludesTransport = true,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Cena Romántica de 3 Tiempos a la Orilla del Mar",
                    Description = "Mesa privada iluminada con antorchas sobre la arena, menú degustación de frutos del mar preparado por nuestro chef, botella de vino blanco y postre de chocolate venezolano.",
                    PriceUsd = 65.00m,
                    Duration = "3 horas (7:00 PM - 10:00 PM)",
                    Category = "Gastronomía",
                    ImageUrl = "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                    IncludesTransport = false,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Sesión de Spa & Masajes Relajantes en Terraza",
                    Description = "Masaje corporal descontracturante de 60 minutos con aceites esenciales de coco y lavanda, aromaterapia marina y té detox con vista al mar.",
                    PriceUsd = 40.00m,
                    Duration = "1 hora y 15 min",
                    Category = "Bienestar",
                    ImageUrl = "https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=800",
                    IncludesTransport = false,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Tour Snorkel en Arrecife & Paseo por Manglares",
                    Description = "Aventura ecológica guiada en lancha rápida hacia la cueva de la virgen, observación de aves exóticas en los manglares y nado guiado con peces tropicales.",
                    PriceUsd = 30.00m,
                    Duration = "4 horas (9:00 AM - 1:00 PM)",
                    Category = "Ecoturismo",
                    ImageUrl = "https://images.unsplash.com/photo-1682687220063-4742bd7c8f1b?w=800",
                    IncludesTransport = true,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                },
                new()
                {
                    Id = Guid.NewGuid(),
                    Title = "Paseo al Atardecer con Tabla de Quesos y Vino",
                    Description = "Travesía crepuscular en velero disfrutando de la puesta de sol en la bahía, degustación de quesos artesanales, charcutería y copa de vino tinto o blanco.",
                    PriceUsd = 50.00m,
                    Duration = "2 horas y media (5:00 PM - 7:30 PM)",
                    Category = "Experiencia Exclusiva",
                    ImageUrl = "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
                    IncludesTransport = true,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-6)
                }
            };

            context.Experiences.AddRange(newExperiences);
            await context.SaveChangesAsync();
        }

        // 5. Seed Complete Historical and Active Bookings & Payments
        var allRooms = await context.Rooms.ToListAsync();
        var bookingsCount = await context.Bookings.CountAsync();

        if (bookingsCount < 5 && allRooms.Any())
        {
            var r101 = allRooms.FirstOrDefault(r => r.RoomNumber == "101") ?? allRooms[0];
            var r102 = allRooms.FirstOrDefault(r => r.RoomNumber == "102") ?? allRooms[0];
            var r201 = allRooms.FirstOrDefault(r => r.RoomNumber == "201") ?? allRooms[0];
            var r202 = allRooms.FirstOrDefault(r => r.RoomNumber == "202") ?? allRooms[0];
            var r204 = allRooms.FirstOrDefault(r => r.RoomNumber == "204") ?? allRooms[0];

            var newBookings = new List<Booking>();
            var newPayments = new List<Payment>();

            // Past Completed Booking 1 (March 2026)
            var bMar = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0315",
                GuestId = guest2.Id,
                RoomId = r101.Id,
                CheckInDate = new DateTime(2026, 3, 12, 15, 0, 0, DateTimeKind.Utc),
                CheckOutDate = new DateTime(2026, 3, 15, 12, 0, 0, DateTimeKind.Utc),
                TotalNights = 3,
                GuestsCount = 2,
                PricePerNightUsd = 45.00m,
                TotalAmountUsd = 135.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedOut,
                CheckedInAt = new DateTime(2026, 3, 12, 15, 30, 0, DateTimeKind.Utc),
                CheckedOutAt = new DateTime(2026, 3, 15, 11, 45, 0, DateTimeKind.Utc),
                CreatedAt = new DateTime(2026, 3, 5, 10, 0, 0, DateTimeKind.Utc),
                SpecialRequests = "Cama matrimonial confortable"
            };
            newBookings.Add(bMar);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bMar.Id,
                AmountUsd = 135.00m,
                AmountVes = 135.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.MobilePay,
                ReferenceNumber = "BANESCO-PM-892104",
                Status = PaymentStatus.Approved,
                ProcessedAt = new DateTime(2026, 3, 5, 10, 15, 0, DateTimeKind.Utc),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = new DateTime(2026, 3, 5, 10, 0, 0, DateTimeKind.Utc)
            });

            // Past Completed Booking 2 (April 2026)
            var bApr = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0422",
                GuestId = guest3.Id,
                RoomId = r204.Id,
                CheckInDate = new DateTime(2026, 4, 18, 15, 0, 0, DateTimeKind.Utc),
                CheckOutDate = new DateTime(2026, 4, 22, 12, 0, 0, DateTimeKind.Utc),
                TotalNights = 4,
                GuestsCount = 2,
                PricePerNightUsd = 160.00m,
                TotalAmountUsd = 640.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedOut,
                CheckedInAt = new DateTime(2026, 4, 18, 16, 0, 0, DateTimeKind.Utc),
                CheckedOutAt = new DateTime(2026, 4, 22, 11, 30, 0, DateTimeKind.Utc),
                CreatedAt = new DateTime(2026, 4, 10, 14, 0, 0, DateTimeKind.Utc),
                SpecialRequests = "Aniversario de bodas - decoración especial"
            };
            newBookings.Add(bApr);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bApr.Id,
                AmountUsd = 640.00m,
                AmountVes = 640.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.Zelle,
                ReferenceNumber = "ZELLE-CONF-948102",
                Status = PaymentStatus.Approved,
                ProcessedAt = new DateTime(2026, 4, 10, 14, 20, 0, DateTimeKind.Utc),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = new DateTime(2026, 4, 10, 14, 0, 0, DateTimeKind.Utc)
            });

            // Past Completed Booking 3 (May 2026)
            var bMay = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0518",
                GuestId = guest1.Id,
                RoomId = r201.Id,
                CheckInDate = new DateTime(2026, 5, 14, 15, 0, 0, DateTimeKind.Utc),
                CheckOutDate = new DateTime(2026, 5, 18, 12, 0, 0, DateTimeKind.Utc),
                TotalNights = 4,
                GuestsCount = 4,
                PricePerNightUsd = 120.00m,
                TotalAmountUsd = 480.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedOut,
                CheckedInAt = new DateTime(2026, 5, 14, 15, 0, 0, DateTimeKind.Utc),
                CheckedOutAt = new DateTime(2026, 5, 18, 12, 0, 0, DateTimeKind.Utc),
                CreatedAt = new DateTime(2026, 5, 2, 9, 0, 0, DateTimeKind.Utc)
            };
            newBookings.Add(bMay);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bMay.Id,
                AmountUsd = 480.00m,
                AmountVes = 480.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.BankTransfer,
                ReferenceNumber = "MERCANTIL-TRF-402918",
                Status = PaymentStatus.Approved,
                ProcessedAt = new DateTime(2026, 5, 2, 9, 30, 0, DateTimeKind.Utc),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = new DateTime(2026, 5, 2, 9, 0, 0, DateTimeKind.Utc)
            });

            // Past Completed Booking 4 (June 2026)
            var bJun = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0628",
                GuestId = guest2.Id,
                RoomId = r102.Id,
                CheckInDate = new DateTime(2026, 6, 24, 15, 0, 0, DateTimeKind.Utc),
                CheckOutDate = new DateTime(2026, 6, 28, 12, 0, 0, DateTimeKind.Utc),
                TotalNights = 4,
                GuestsCount = 2,
                PricePerNightUsd = 95.00m,
                TotalAmountUsd = 380.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedOut,
                CheckedInAt = new DateTime(2026, 6, 24, 15, 0, 0, DateTimeKind.Utc),
                CheckedOutAt = new DateTime(2026, 6, 28, 11, 0, 0, DateTimeKind.Utc),
                CreatedAt = new DateTime(2026, 6, 15, 11, 0, 0, DateTimeKind.Utc)
            };
            newBookings.Add(bJun);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bJun.Id,
                AmountUsd = 380.00m,
                AmountVes = 380.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.MobilePay,
                ReferenceNumber = "BDV-PM-551029",
                Status = PaymentStatus.Approved,
                ProcessedAt = new DateTime(2026, 6, 15, 11, 15, 0, DateTimeKind.Utc),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = new DateTime(2026, 6, 15, 11, 0, 0, DateTimeKind.Utc)
            });

            // Past Completed Booking 5 (July 2026 - Vacaciones)
            var bJul = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0720",
                GuestId = guest3.Id,
                RoomId = r201.Id,
                CheckInDate = new DateTime(2026, 7, 15, 15, 0, 0, DateTimeKind.Utc),
                CheckOutDate = new DateTime(2026, 7, 20, 12, 0, 0, DateTimeKind.Utc),
                TotalNights = 5,
                GuestsCount = 5,
                PricePerNightUsd = 120.00m,
                TotalAmountUsd = 600.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedOut,
                CheckedInAt = new DateTime(2026, 7, 15, 15, 0, 0, DateTimeKind.Utc),
                CheckedOutAt = new DateTime(2026, 7, 20, 11, 30, 0, DateTimeKind.Utc),
                CreatedAt = new DateTime(2026, 7, 1, 16, 0, 0, DateTimeKind.Utc)
            };
            newBookings.Add(bJul);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bJul.Id,
                AmountUsd = 600.00m,
                AmountVes = 600.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.Cash,
                ReferenceNumber = "EFECTIVO-REC-00128",
                Status = PaymentStatus.Approved,
                ProcessedAt = new DateTime(2026, 7, 15, 15, 30, 0, DateTimeKind.Utc),
                ApprovedByUserId = recepcionUser.Id,
                CreatedAt = new DateTime(2026, 7, 1, 16, 0, 0, DateTimeKind.Utc)
            });

            // Current Active Booking 1 (CheckedIn - Habitación 101)
            var bAug1 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0818",
                GuestId = guest1.Id,
                RoomId = r101.Id,
                CheckInDate = DateTime.UtcNow.Date.AddDays(-1),
                CheckOutDate = DateTime.UtcNow.Date.AddDays(2),
                TotalNights = 3,
                GuestsCount = 2,
                PricePerNightUsd = 45.00m,
                TotalAmountUsd = 135.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedIn,
                CheckedInAt = DateTime.UtcNow.AddDays(-1).AddHours(3),
                CreatedAt = DateTime.UtcNow.AddDays(-4),
                SpecialRequests = "Check-in temprano y almohadas extras"
            };
            newBookings.Add(bAug1);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bAug1.Id,
                AmountUsd = 135.00m,
                AmountVes = 135.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.MobilePay,
                ReferenceNumber = "BANESCO-PM-992014",
                Status = PaymentStatus.Approved,
                ProcessedAt = DateTime.UtcNow.AddDays(-4),
                ApprovedByUserId = adminUser.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-4)
            });

            // Current Active Booking 2 (CheckedIn - Habitación 201)
            var bAug2 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0819",
                GuestId = guest2.Id,
                RoomId = r201.Id,
                CheckInDate = DateTime.UtcNow.Date,
                CheckOutDate = DateTime.UtcNow.Date.AddDays(3),
                TotalNights = 3,
                GuestsCount = 4,
                PricePerNightUsd = 120.00m,
                TotalAmountUsd = 360.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.CheckedIn,
                CheckedInAt = DateTime.UtcNow.AddHours(-2),
                CreatedAt = DateTime.UtcNow.AddDays(-3),
                SpecialRequests = "Cuna de bebé y estacionamiento techado"
            };
            newBookings.Add(bAug2);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bAug2.Id,
                AmountUsd = 360.00m,
                AmountVes = 360.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.Zelle,
                ReferenceNumber = "ZELLE-TRX-778819",
                Status = PaymentStatus.Approved,
                ProcessedAt = DateTime.UtcNow.AddDays(-3),
                ApprovedByUserId = recepcionUser.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-3)
            });

            // Confirmed Upcoming Booking 3 (Habitación 202 para mañana)
            var bAug3 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0820",
                GuestId = guest3.Id,
                RoomId = r202.Id,
                CheckInDate = DateTime.UtcNow.Date.AddDays(1),
                CheckOutDate = DateTime.UtcNow.Date.AddDays(4),
                TotalNights = 3,
                GuestsCount = 3,
                PricePerNightUsd = 75.00m,
                TotalAmountUsd = 225.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.Confirmed,
                CreatedAt = DateTime.UtcNow.AddDays(-1),
                SpecialRequests = "Llegada aproximada a las 4:00 PM"
            };
            newBookings.Add(bAug3);
            newPayments.Add(new Payment
            {
                Id = Guid.NewGuid(),
                BookingId = bAug3.Id,
                AmountUsd = 225.00m,
                AmountVes = 225.00m * bcv,
                ExchangeRate = bcv,
                Method = PaymentMethod.MobilePay,
                ReferenceNumber = "MERCANTIL-PM-331049",
                Status = PaymentStatus.Approved,
                ProcessedAt = DateTime.UtcNow.AddDays(-1),
                ApprovedByUserId = recepcionUser.Id,
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            });

            // Pending Booking 4 (Habitación 102 por aprobar)
            var bAug4 = new Booking
            {
                Id = Guid.NewGuid(),
                BookingCode = "POS-2026-0822",
                GuestId = guest2.Id,
                RoomId = r102.Id,
                CheckInDate = DateTime.UtcNow.Date.AddDays(3),
                CheckOutDate = DateTime.UtcNow.Date.AddDays(5),
                TotalNights = 2,
                GuestsCount = 2,
                PricePerNightUsd = 95.00m,
                TotalAmountUsd = 190.00m,
                ExchangeRateUsed = bcv,
                Status = BookingStatus.Pending,
                CreatedAt = DateTime.UtcNow.AddHours(-4),
                SpecialRequests = "Piso alto y vista al mar despejada"
            };
            newBookings.Add(bAug4);

            context.Bookings.AddRange(newBookings);
            context.Payments.AddRange(newPayments);

            r101.Status = RoomStatus.Occupied;
            r102.Status = RoomStatus.NeedsCleaning;
            r201.Status = RoomStatus.Occupied;

            await context.SaveChangesAsync();
        }
    }
}
