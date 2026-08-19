using Microsoft.EntityFrameworkCore;
using Posada.Application.Interfaces;
using Posada.Domain.Entities;

namespace Posada.Infrastructure.Data;

public class AppDbContext : DbContext, IAppDbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<Booking> Bookings => Set<Booking>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<ExtraCharge> ExtraCharges => Set<ExtraCharge>();
    public DbSet<HotelSetting> HotelSettings => Set<HotelSetting>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<Experience> Experiences => Set<Experience>();
    public DbSet<PromoCode> PromoCodes => Set<PromoCode>();
    public DbSet<NotificationItem> Notifications => Set<NotificationItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User Configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Username).IsUnique();
            entity.Property(e => e.FullName).HasMaxLength(150).IsRequired();
            entity.Property(e => e.Email).HasMaxLength(150).IsRequired();
            entity.Property(e => e.Username).HasMaxLength(50).IsRequired();
            entity.Property(e => e.PhoneNumber).HasMaxLength(30);
            entity.Property(e => e.Role).HasConversion<string>();
        });

        // Room Configuration
        modelBuilder.Entity<Room>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.RoomNumber).IsUnique();
            entity.Property(e => e.RoomNumber).HasMaxLength(20).IsRequired();
            entity.Property(e => e.Title).HasMaxLength(100).IsRequired();
            entity.Property(e => e.PricePerNightUsd).HasPrecision(18, 2);
            entity.Property(e => e.Type).HasConversion<string>();
            entity.Property(e => e.Status).HasConversion<string>();
        });

        // Booking Configuration
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.BookingCode).IsUnique();
            entity.Property(e => e.BookingCode).HasMaxLength(30).IsRequired();
            entity.Property(e => e.PricePerNightUsd).HasPrecision(18, 2);
            entity.Property(e => e.TotalAmountUsd).HasPrecision(18, 2);
            entity.Property(e => e.ExchangeRateUsed).HasPrecision(18, 2);
            entity.Property(e => e.Status).HasConversion<string>();

            entity.HasOne(e => e.Guest)
                .WithMany(u => u.Bookings)
                .HasForeignKey(e => e.GuestId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Room)
                .WithMany(r => r.Bookings)
                .HasForeignKey(e => e.RoomId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Payment Configuration
        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.AmountUsd).HasPrecision(18, 2);
            entity.Property(e => e.AmountVes).HasPrecision(18, 2);
            entity.Property(e => e.ExchangeRate).HasPrecision(18, 2);
            entity.Property(e => e.Method).HasConversion<string>();
            entity.Property(e => e.Status).HasConversion<string>();

            entity.HasOne(e => e.Booking)
                .WithMany(b => b.Payments)
                .HasForeignKey(e => e.BookingId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // ExtraCharge Configuration
        modelBuilder.Entity<ExtraCharge>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.AmountUsd).HasPrecision(18, 2);

            entity.HasOne(e => e.Booking)
                .WithMany(b => b.ExtraCharges)
                .HasForeignKey(e => e.BookingId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // HotelSetting Configuration
        modelBuilder.Entity<HotelSetting>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.UsdExchangeRateBcv).HasPrecision(18, 2);
        });

        // Review Configuration
        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Room).WithMany().HasForeignKey(e => e.RoomId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Guest).WithMany().HasForeignKey(e => e.GuestId).OnDelete(DeleteBehavior.Cascade);
        });

        // Experience Configuration
        modelBuilder.Entity<Experience>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.PriceUsd).HasPrecision(18, 2);
        });

        // PromoCode Configuration
        modelBuilder.Entity<PromoCode>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Code).IsUnique();
            entity.Property(e => e.DiscountPercentage).HasPrecision(18, 2);
            entity.Property(e => e.MaxDiscountUsd).HasPrecision(18, 2);
        });

        // Notification Configuration
        modelBuilder.Entity<NotificationItem>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }
}
