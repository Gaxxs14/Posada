import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _usdFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _vesFormatter = NumberFormat.currency(
    symbol: 'Bs. ',
    decimalDigits: 2,
    locale: 'es_VE',
  );

  static String formatUsd(double amount) {
    return _usdFormatter.format(amount);
  }

  static String formatVes(double amount) {
    return _vesFormatter.format(amount);
  }

  static String formatDual(double amountUsd, double exchangeRate) {
    final usdStr = formatUsd(amountUsd);
    final vesStr = formatVes(amountUsd * exchangeRate);
    return '$usdStr ($vesStr)';
  }
}
