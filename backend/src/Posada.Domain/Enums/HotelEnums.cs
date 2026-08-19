namespace Posada.Domain.Enums;

public enum UserRole
{
    Admin,
    Receptionist,
    Guest,
    Housekeeping
}

public enum RoomStatus
{
    Available,
    Occupied,
    NeedsCleaning,
    UnderMaintenance
}

public enum RoomType
{
    Single,
    Double,
    Triple,
    Suite,
    Family
}

public enum BookingStatus
{
    Pending,
    Confirmed,
    CheckedIn,
    CheckedOut,
    Cancelled
}

public enum PaymentMethod
{
    Cash,
    MobilePay,
    Zelle,
    Card,
    BankTransfer
}

public enum PaymentStatus
{
    Pending,
    Approved,
    Rejected
}
