class ApiEndpoints {
  // In development, you can point to localhost:8080 (or 5000/http://10.0.2.2:8080 on Android emulator)
  // In production, point to your Render deployment URL: https://posada-pro.onrender.com
  static const String baseUrl = 'http://localhost:8080';

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
