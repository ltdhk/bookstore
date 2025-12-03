import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/subscription/data/subscription_api_service.dart';
import 'package:novelpop/src/features/subscription/data/models/subscription_product.dart';
import 'package:novelpop/src/features/subscription/data/models/subscription_status.dart';
import 'package:novelpop/src/services/iap/in_app_purchase_service.dart';
import 'dart:io' show Platform;

part 'subscription_provider.g.dart';

/// Provider for InAppPurchaseService
@riverpod
InAppPurchaseService inAppPurchaseService(Ref ref) {
  return InAppPurchaseService(
    ref.watch(subscriptionApiServiceProvider),
  );
}

/// Provider for subscription products list
@riverpod
Future<List<SubscriptionProduct>> subscriptionProducts(Ref ref, {String? platform}) async {
  final apiService = ref.watch(subscriptionApiServiceProvider);
  return await apiService.getProducts(platform: platform);
}

/// Provider for current user subscription status
@riverpod
Future<SubscriptionStatus> subscriptionStatus(Ref ref) async {
  final apiService = ref.watch(subscriptionApiServiceProvider);
  return await apiService.getSubscriptionStatus();
}

/// Provider for subscription validity
@riverpod
Future<bool> subscriptionValid(Ref ref) async {
  final apiService = ref.watch(subscriptionApiServiceProvider);
  return await apiService.isSubscriptionValid();
}

/// Get platform based on current device
String getCurrentPlatform() {
  try {
    if (Platform.isIOS) return 'AppStore';
    if (Platform.isAndroid) return 'GooglePay';
  } catch (e) {
    // If Platform is not available (web, etc.), default to AppStore
  }
  return 'AppStore';
}

/// Provider for platform-specific subscription products
@riverpod
Future<List<SubscriptionProduct>> platformSubscriptionProducts(Ref ref) async {
  final platform = getCurrentPlatform();
  return await ref.watch(subscriptionProductsProvider(platform: platform).future);
}

/// Provider for grouped subscription products (monthly, quarterly, yearly)
@riverpod
Future<Map<String, SubscriptionProduct>> groupedSubscriptionProducts(Ref ref) async {
  final products = await ref.watch(platformSubscriptionProductsProvider.future);

  final Map<String, SubscriptionProduct> grouped = {};
  for (final product in products) {
    grouped[product.planType] = product;
  }

  return grouped;
}
