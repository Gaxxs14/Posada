import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Production backend URL
  static const String _backendUrl = 'https://posada-0nkr.onrender.com';

  /// On web, the Flutter app is served FROM the .NET backend itself,
  /// so we use an empty base URL (same-origin). This eliminates CORS entirely.
  /// On mobile (Android/iOS), we use the full backend URL.
  static String get baseUrl => kIsWeb ? '' : _backendUrl;

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/me';
  static const String changePassword = '/api/auth/change-password';

  // Rooms
  static const String rooms = '/api/rooms';

  // Bookings
  static const String bookings = '/api/bookings';
  static const String bookingQuote = '/api/bookings/quote';
  static const String myBookings = '/api/bookings/my-bookings';

  // Dashboard & Settings
  static const String dashboardStats = '/api/dashboard/stats';
  static const String settings = '/api/settings';
  static const String exchangeRate = '/api/settings/exchange-rate';
}
