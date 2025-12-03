import 'package:intl/intl.dart';

/// Utility class for formatting numbers
class NumberFormatter {
  /// Format number with thousand separators
  /// Example: 1234567 -> "1,234,567"
  static String format(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// Format large numbers with abbreviations (K, M, B)
  /// Example: 1500 -> "1.5K", 1500000 -> "1.5M"
  static String formatCompact(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
  }

  /// Format decimal number
  /// Example: 4.567 -> "4.57"
  static String formatDecimal(double number, int decimalDigits) {
    return number.toStringAsFixed(decimalDigits);
  }

  /// Format percentage
  /// Example: 0.2567 -> "25.67%"
  static String formatPercentage(double value, {int decimalDigits = 2}) {
    final percentage = value * 100;
    return '${percentage.toStringAsFixed(decimalDigits)}%';
  }

  /// Format number with custom pattern
  static String formatCustom(num number, String pattern) {
    final formatter = NumberFormat(pattern);
    return formatter.format(number);
  }
}
