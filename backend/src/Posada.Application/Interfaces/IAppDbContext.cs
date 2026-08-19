using Microsoft.EntityFrameworkCore;
using Posada.Domain.Entities;

namespace Posada.Application.Interfaces;

public interface IAppDbContext
{
    DbSet<User> Users { get; }
    DbSet<Room> Rooms { get; }
    DbSet<Booking> Bookings { get; }
    DbSet<Payment> Payments { get; }
    DbSet<ExtraCharge> ExtraCharges { get; }
    DbSet<HotelSetting> HotelSettings { get; }
    DbSet<Review> Reviews { get; }
    DbSet<Experience> Experiences { get; }
    DbSet<PromoCode> PromoCodes { get; }
    DbSet<NotificationItem> Notifications { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
