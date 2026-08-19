class ApiEndpoints {
  // Production backend URL (always full URL - CORS is configured to allow all origins)
  static const String baseUrl = 'https://posada-0nkr.onrender.com';

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
