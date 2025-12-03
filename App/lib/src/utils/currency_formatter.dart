import 'package:intl/intl.dart';

/// Utility class for formatting currency values
/// All currency is displayed in USD ($) regardless of locale
class CurrencyFormatter {
  /// Format amount as USD currency
  /// Example: 9.99 -> "$9.99"
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format amount as USD currency without symbol
  /// Example: 9.99 -> "9.99"
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(amount).trim();
  }

  /// Format amount with custom decimal digits
  static String formatWithDecimals(double amount, int decimalDigits) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }
}
