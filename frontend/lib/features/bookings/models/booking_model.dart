class BookingModel {
  final String id;
  final String bookingCode;
  final String guestId;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String roomId;
  final String roomNumber;
  final String roomTitle;
  final String roomType;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalNights;
  final int guestsCount;
  final double pricePerNightUsd;
  final double totalAmountUsd;
  final double exchangeRateUsed;
  final double totalAmountVes;
  final String status;
  final String? specialRequests;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final double totalPaidUsd;
  final double remainingBalanceUsd;

  BookingModel({
    required this.id,
    required this.bookingCode,
    required this.guestId,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.roomId,
    required this.roomNumber,
    required this.roomTitle,
    required this.roomType,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.guestsCount,
    required this.pricePerNightUsd,
    required this.totalAmountUsd,
    required this.exchangeRateUsed,
    required this.totalAmountVes,
    required this.status,
    this.specialRequests,
    this.adminNotes,
    required this.createdAt,
    this.checkedInAt,
    this.checkedOutAt,
    required this.totalPaidUsd,
    required this.remainingBalanceUsd,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isCheckedIn => status.toLowerCase() == 'checkedin';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      bookingCode: json['bookingCode'] ?? '',
      guestId: json['guestId'] ?? '',
      guestName: json['guestName'] ?? 'Huésped',
      guestEmail: json['guestEmail'] ?? '',
      guestPhone: json['guestPhone'] ?? '',
      roomId: json['roomId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      roomTitle: json['roomTitle'] ?? '',
      roomType: json['roomType']?.toString() ?? 'Double',
      checkInDate: DateTime.tryParse(json['checkInDate']?.toString() ?? '') ?? DateTime.now(),
      checkOutDate: DateTime.tryParse(json['checkOutDate']?.toString() ?? '') ?? DateTime.now(),
      totalNights: json['totalNights'] ?? 1,
      guestsCount: json['guestsCount'] ?? 1,
      pricePerNightUsd: (json['pricePerNightUsd'] as num?)?.toDouble() ?? 0.0,
      totalAmountUsd: (json['totalAmountUsd'] as num?)?.toDouble() ?? 0.0,
      exchangeRateUsed: (json['exchangeRateUsed'] as num?)?.toDouble() ?? 765.0,
      totalAmountVes: (json['totalAmountVes'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'Pending',
      specialRequests: json['specialRequests'],
      adminNotes: json['adminNotes'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      checkedInAt: DateTime.tryParse(json['checkedInAt']?.toString() ?? ''),
      checkedOutAt: DateTime.tryParse(json['checkedOutAt']?.toString() ?? ''),
      totalPaidUsd: (json['totalPaidUsd'] as num?)?.toDouble() ?? 0.0,
      remainingBalanceUsd: (json['remainingBalanceUsd'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BookingQuoteModel {
  final String roomId;
  final String roomNumber;
  final String roomTitle;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalNights;
  final double pricePerNightUsd;
  final double totalAmountUsd;
  final double currentExchangeRateBcv;
  final double totalAmountVes;
  final bool isAvailable;

  BookingQuoteModel({
    required this.roomId,
    required this.roomNumber,
    required this.roomTitle,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.pricePerNightUsd,
    required this.totalAmountUsd,
    required this.currentExchangeRateBcv,
    required this.totalAmountVes,
    required this.isAvailable,
  });

  factory BookingQuoteModel.fromJson(Map<String, dynamic> json) {
    return BookingQuoteModel(
      roomId: json['roomId'] ?? '',
      roomNumber: json['roomNumber'] ?? '',
      roomTitle: json['roomTitle'] ?? '',
      checkInDate: DateTime.tryParse(json['checkInDate']?.toString() ?? '') ?? DateTime.now(),
      checkOutDate: DateTime.tryParse(json['checkOutDate']?.toString() ?? '') ?? DateTime.now(),
      totalNights: json['totalNights'] ?? 1,
      pricePerNightUsd: (json['pricePerNightUsd'] as num?)?.toDouble() ?? 0.0,
      totalAmountUsd: (json['totalAmountUsd'] as num?)?.toDouble() ?? 0.0,
      currentExchangeRateBcv: (json['currentExchangeRateBcv'] as num?)?.toDouble() ?? 765.0,
      totalAmountVes: (json['totalAmountVes'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}
