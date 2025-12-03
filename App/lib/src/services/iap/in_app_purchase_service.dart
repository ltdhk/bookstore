import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:novelpop/src/features/subscription/data/subscription_api_service.dart';

/// In-App Purchase service
/// Handles all IAP operations for both iOS and Android
class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionApiService _apiService;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  // Callbacks for purchase events
  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(PurchaseDetails, String)? onPurchaseError;
  Function()? onPurchasePending;

  InAppPurchaseService(this._apiService);

  /// Initialize IAP service
  Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    try {
      // Check if IAP is available
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('IAP not available on this device');
        return false;
      }

      // Platform-specific initialization
      if (Platform.isIOS) {
        // iOS-specific setup if needed
        _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      }

      // Listen to purchase stream
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          debugPrint('Purchase stream error: $error');
        },
      );

      _isInitialized = true;
      debugPrint('IAP service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize IAP: $e');
      return false;
    }
  }

  /// Query products from store
  Future<List<ProductDetails>> queryProducts(Set<String> productIds) async {
    try {
      final response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        throw Exception('Failed to query products: ${response.error}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      return response.productDetails;
    } catch (e) {
      debugPrint('Failed to query products: $e');
      rethrow;
    }
  }

  /// Purchase a product
  Future<void> purchaseProduct(
    ProductDetails productDetails, {
    required String platform,
    required String productId,
    int? distributorId,
    int? sourcePasscodeId,
    int? sourceBookId,
    String? sourceEntry,
  }) async {
    try {
      final purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null, // Can be used for server-side verification
      );

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      // Store context for verification
      _pendingPurchaseContext = {
        'platform': platform,
        'productId': productId,
        'distributorId': distributorId,
        'sourcePasscodeId': sourcePasscodeId,
        'sourceBookId': sourceBookId,
        'sourceEntry': sourceEntry,
      };
    } catch (e) {
      debugPrint('Failed to purchase product: $e');
      rethrow;
    }
  }

  Map<String, dynamic>? _pendingPurchaseContext;

  /// Handle purchase updates from stream
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      debugPrint('Purchase update: ${purchase.status}');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _handlePending();
          break;
        case PurchaseStatus.purchased:
          _handlePurchase(purchase);
          break;
        case PurchaseStatus.error:
          _handleError(purchase);
          break;
        case PurchaseStatus.restored:
          _handleRestore(purchase);
          break;
        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled');
          break;
      }
    }
  }

  /// Handle pending purchase
  void _handlePending() {
    debugPrint('Purchase is pending');
    onPurchasePending?.call();
  }

  /// Handle successful purchase
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    try {
      debugPrint('Processing purchase: ${purchase.productID}');

      // Verify with backend
      await _verifyWithBackend(purchase);

      // Complete the purchase
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
        debugPrint('Purchase completed');
      }

      // Notify success
      onPurchaseSuccess?.call(purchase);
    } catch (e) {
      debugPrint('Failed to process purchase: $e');
      onPurchaseError?.call(purchase, e.toString());
    }
  }

  /// Handle purchase error
  void _handleError(PurchaseDetails purchase) {
    final error = purchase.error?.message ?? 'Unknown error';
    debugPrint('Purchase error: $error');
    onPurchaseError?.call(purchase, error);
  }

  /// Handle restored purchase
  Future<void> _handleRestore(PurchaseDetails purchase) async {
    debugPrint('Restoring purchase: ${purchase.productID}');
    await _handlePurchase(purchase);
  }

  /// Verify purchase with backend
  Future<void> _verifyWithBackend(PurchaseDetails purchase) async {
    debugPrint('========== 开始后端验证购买 ==========');
    final receiptData = purchase.verificationData.serverVerificationData;
    final context = _pendingPurchaseContext ?? {};
    final platform = Platform.isIOS ? 'AppStore' : 'GooglePay';

    debugPrint('购买详情 - 产品ID: ${purchase.productID}, 平台: $platform');
    debugPrint('来源信息 - 分销商ID: ${context['distributorId']}, 口令ID: ${context['sourcePasscodeId']}');
    debugPrint('来源信息 - 书籍ID: ${context['sourceBookId']}, 入口: ${context['sourceEntry']}');

    try {
      debugPrint('调用后端验证接口...');
      final result = await _apiService.verifyPurchase(
        platform: platform,
        productId: context['productId'] as String? ?? purchase.productID,
        receiptData: Platform.isIOS ? receiptData : null,
        purchaseToken: Platform.isAndroid ? receiptData : null,
        distributorId: context['distributorId'] as int?,
        sourcePasscodeId: context['sourcePasscodeId'] as int?,
        sourceBookId: context['sourceBookId'] as int?,
        sourceEntry: context['sourceEntry'] as String?,
      );

      debugPrint('后端验证成功! 订单信息: $result');
      debugPrint('========== 购买验证完成 ==========');
    } catch (e) {
      debugPrint('后端验证失败: $e');
      debugPrint('========== 购买验证失败 ==========');
      rethrow;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      debugPrint('Restore purchases initiated');
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      rethrow;
    }
  }

  /// Dispose service
  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
  }
}
