import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/services/networking/dio_provider.dart';
import 'package:novelpop/src/features/subscription/data/models/subscription_product.dart';
import 'package:novelpop/src/features/subscription/data/models/subscription_status.dart';
import 'package:novelpop/src/features/subscription/data/models/subscription_create_request.dart';

part 'subscription_api_service.g.dart';

@riverpod
SubscriptionApiService subscriptionApiService(Ref ref) {
  return SubscriptionApiService(ref.watch(dioProvider));
}

class SubscriptionApiService {
  final Dio _dio;

  SubscriptionApiService(this._dio);

  /// Get subscription products
  /// @param platform Optional platform filter (AppStore/GooglePay)
  Future<List<SubscriptionProduct>> getProducts({String? platform}) async {
    final Map<String, dynamic> queryParams = {};
    if (platform != null) {
      queryParams['platform'] = platform;
    }

    final response = await _dio.get(
      '/api/subscription/products',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data['data'] as List;
    return data
        .map((json) => SubscriptionProduct.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create subscription (simulated payment)
  /// Requires JWT token authentication
  Future<Map<String, dynamic>> createSubscription(
    SubscriptionCreateRequest request,
  ) async {
    final response = await _dio.post(
      '/api/subscription/create',
      data: request.toJson(),
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  /// Get current user subscription status
  /// Requires JWT token authentication
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    final response = await _dio.get('/api/subscription/status');
    final data = response.data['data'] as Map<String, dynamic>;
    return SubscriptionStatus.fromJson(data);
  }

  /// Cancel subscription
  /// @param reason Optional cancellation reason
  /// Requires JWT token authentication
  Future<String> cancelSubscription({String? reason}) async {
    final Map<String, dynamic> queryParams = {};
    if (reason != null) {
      queryParams['reason'] = reason;
    }

    final response = await _dio.post(
      '/api/subscription/cancel',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return response.data['data'] as String;
  }

  /// Check if subscription is valid
  /// Requires JWT token authentication
  Future<bool> isSubscriptionValid() async {
    final response = await _dio.get('/api/subscription/valid');
    return response.data['data'] as bool;
  }

  /// Verify purchase receipt with backend
  /// Requires JWT token authentication
  Future<Map<String, dynamic>> verifyPurchase({
    required String platform,
    required String productId,
    String? receiptData,
    String? purchaseToken,
    int? distributorId,
    int? sourcePasscodeId,
    int? sourceBookId,
    String? sourceEntry,
  }) async {
    final response = await _dio.post(
      '/api/subscription/verify',
      data: {
        'platform': platform,
        'productId': productId,
        if (receiptData != null) 'receiptData': receiptData,
        if (purchaseToken != null) 'purchaseToken': purchaseToken,
        if (distributorId != null) 'distributorId': distributorId,
        if (sourcePasscodeId != null) 'sourcePasscodeId': sourcePasscodeId,
        if (sourceBookId != null) 'sourceBookId': sourceBookId,
        if (sourceEntry != null) 'sourceEntry': sourceEntry,
      },
    );

    return response.data['data'] as Map<String, dynamic>;
  }
}
