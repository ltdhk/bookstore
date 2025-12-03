import 'dart:io';

/// Platform-specific product ID configuration
/// Maps internal product IDs to Apple/Google product IDs
class PlatformProductConfig {
  // Apple App Store product IDs
  static const String appleWeekly = 'com.novel.pop.weekly';
  static const String appleMonthly = 'com.novel.pop.monthly';
  static const String appleYearly = 'com.novel.pop.yearly';

  // Google Play product IDs
  static const String googleWeekly = 'novelpop_weekly';
  static const String googleMonthly = 'novelpop_monthly';
  static const String googleYearly = 'novelpop_yearly';

  /// Get platform-specific product ID based on plan type
  static String getPlatformProductId(String planType) {
    if (Platform.isIOS) {
      switch (planType) {
        case 'weekly':
          return appleWeekly;
        case 'monthly':
          return appleMonthly;
        case 'yearly':
          return appleYearly;
        default:
          throw Exception('Unknown plan type: $planType');
      }
    } else if (Platform.isAndroid) {
      switch (planType) {
        case 'weekly':
          return googleWeekly;
        case 'monthly':
          return googleMonthly;
        case 'yearly':
          return googleYearly;
        default:
          throw Exception('Unknown plan type: $planType');
      }
    } else {
      throw Exception('Unsupported platform');
    }
  }

  /// Get all platform product IDs as a set
  static Set<String> getAllPlatformProductIds() {
    if (Platform.isIOS) {
      return {appleWeekly, appleMonthly, appleYearly};
    } else if (Platform.isAndroid) {
      return {googleWeekly, googleMonthly, googleYearly};
    } else {
      return {};
    }
  }
}
