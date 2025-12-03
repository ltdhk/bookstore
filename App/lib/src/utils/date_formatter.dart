import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:novelpop/l10n/app_localizations.dart';

/// Utility class for formatting dates and times
class DateFormatter {
  /// Format date as relative time (e.g., "Just now", "5 minutes ago", "Today 14:30")
  /// Requires AppLocalizations for i18n support
  static String formatRelativeTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      final time = DateFormat('HH:mm').format(dateTime);
      return l10n.todayAt(time);
    } else if (difference.inDays < 2) {
      final time = DateFormat('HH:mm').format(dateTime);
      return l10n.yesterdayAt(time);
    } else {
      return DateFormat('MM-dd HH:mm').format(dateTime);
    }
  }

  /// Format date as "yyyy-MM-dd"
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Format date as "MM/dd/yyyy"
  static String formatDateUS(DateTime dateTime) {
    return DateFormat('MM/dd/yyyy').format(dateTime);
  }

  /// Format time as "HH:mm"
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format date and time as "yyyy-MM-dd HH:mm"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  /// Format date with custom pattern
  static String formatCustom(DateTime dateTime, String pattern) {
    return DateFormat(pattern).format(dateTime);
  }
}
