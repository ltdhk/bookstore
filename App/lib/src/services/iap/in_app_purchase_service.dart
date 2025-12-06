import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novelpop/src/features/subscription/data/subscription_api_service.dart';

/// 购买上下文存储键
const String _purchaseContextKey = 'pending_purchase_context';
/// 已完成交易ID的存储键（持久化防止重复处理）
const String _completedTransactionsKey = 'completed_transaction_ids';

/// In-App Purchase service
/// Handles all IAP operations for both iOS and Android
class InAppPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionApiService _apiService;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  // 防止重复处理的锁
  bool _isProcessingPurchase = false;
  // 正在处理的交易ID集合，用于防止同一交易被多次处理（内存缓存）
  final Set<String> _processingTransactionIds = {};
  // 记录交易ID添加的时间，用于定期清理
  final Map<String, DateTime> _transactionIdTimestamps = {};
  // 已完成的交易ID集合（从持久化存储加载，防止 App 重启后重复处理）
  Set<String> _completedTransactionIds = {};

  // Callbacks for purchase events
  Function(PurchaseDetails)? onPurchaseSuccess;
  Function(PurchaseDetails, String)? onPurchaseError;
  Function()? onPurchasePending;
  Function()? onPurchaseCanceled;

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

      // 加载已完成的交易ID
      await _loadCompletedTransactionIds();

      // Listen to purchase stream
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          debugPrint('Purchase stream error: $error');
        },
      );

      // Handle pending transactions on startup
      await _handlePendingTransactions();

      // 定期清理过期的交易ID记录（1小时前的）
      _cleanupOldTransactionIds();

      _isInitialized = true;
      debugPrint('IAP service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize IAP: $e');
      return false;
    }
  }

  /// 加载已完成的交易ID（持久化存储）
  Future<void> _loadCompletedTransactionIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsJson = prefs.getString(_completedTransactionsKey);
      if (idsJson != null) {
        final Map<String, dynamic> data = jsonDecode(idsJson);
        // 只保留7天内的记录
        final now = DateTime.now();
        final validIds = <String>{};
        data.forEach((id, timestampStr) {
          try {
            final timestamp = DateTime.parse(timestampStr as String);
            if (now.difference(timestamp).inDays < 7) {
              validIds.add(id);
            }
          } catch (_) {}
        });
        _completedTransactionIds = validIds;
        debugPrint('加载了 ${_completedTransactionIds.length} 个已完成的交易ID');
      }
    } catch (e) {
      debugPrint('加载已完成交易ID失败: $e');
    }
  }

  /// 保存已完成的交易ID（持久化存储）
  Future<void> _saveCompletedTransactionId(String transactionId) async {
    try {
      _completedTransactionIds.add(transactionId);
      final prefs = await SharedPreferences.getInstance();

      // 加载现有数据
      Map<String, dynamic> data = {};
      final existingJson = prefs.getString(_completedTransactionsKey);
      if (existingJson != null) {
        data = jsonDecode(existingJson) as Map<String, dynamic>;
      }

      // 添加新的交易ID
      data[transactionId] = DateTime.now().toIso8601String();

      // 清理超过7天的记录
      final now = DateTime.now();
      data.removeWhere((id, timestampStr) {
        try {
          final timestamp = DateTime.parse(timestampStr as String);
          return now.difference(timestamp).inDays >= 7;
        } catch (_) {
          return true;
        }
      });

      await prefs.setString(_completedTransactionsKey, jsonEncode(data));
      debugPrint('已保存交易ID到持久化存储: $transactionId');
    } catch (e) {
      debugPrint('保存已完成交易ID失败: $e');
    }
  }

  /// 清理超过1小时的交易ID记录，防止内存泄漏
  void _cleanupOldTransactionIds() {
    final now = DateTime.now();
    final expiredIds = <String>[];

    _transactionIdTimestamps.forEach((id, timestamp) {
      if (now.difference(timestamp).inHours >= 1) {
        expiredIds.add(id);
      }
    });

    for (final id in expiredIds) {
      _processingTransactionIds.remove(id);
      _transactionIdTimestamps.remove(id);
    }

    if (expiredIds.isNotEmpty) {
      debugPrint('清理了 ${expiredIds.length} 个过期的交易ID记录');
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
        applicationUserName: null,
      );

      // 持久化存储购买上下文，防止 App 重启后丢失
      await _savePurchaseContext({
        'platform': platform,
        'productId': productId,
        'distributorId': distributorId,
        'sourcePasscodeId': sourcePasscodeId,
        'sourceBookId': sourceBookId,
        'sourceEntry': sourceEntry,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Failed to purchase product: $e');
      // 购买失败时清理上下文
      await _clearPurchaseContext();
      rethrow;
    }
  }

  /// 持久化保存购买上下文
  Future<void> _savePurchaseContext(Map<String, dynamic> context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_purchaseContextKey, jsonEncode(context));
      debugPrint('购买上下文已持久化保存');
    } catch (e) {
      debugPrint('保存购买上下文失败: $e');
    }
  }

  /// 加载持久化的购买上下文
  Future<Map<String, dynamic>?> _loadPurchaseContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contextStr = prefs.getString(_purchaseContextKey);
      if (contextStr != null) {
        final context = jsonDecode(contextStr) as Map<String, dynamic>;
        // 检查是否过期（24小时）
        final timestamp = context['timestamp'] as String?;
        if (timestamp != null) {
          final savedTime = DateTime.parse(timestamp);
          if (DateTime.now().difference(savedTime).inHours < 24) {
            debugPrint('加载了持久化的购买上下文');
            return context;
          } else {
            debugPrint('购买上下文已过期，清除');
            await _clearPurchaseContext();
          }
        }
      }
    } catch (e) {
      debugPrint('加载购买上下文失败: $e');
    }
    return null;
  }

  /// 清除持久化的购买上下文
  Future<void> _clearPurchaseContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_purchaseContextKey);
      debugPrint('购买上下文已清除');
    } catch (e) {
      debugPrint('清除购买上下文失败: $e');
    }
  }

  /// Handle pending transactions on app startup
  Future<void> _handlePendingTransactions() async {
    try {
      debugPrint('Checking for pending transactions...');

      // The purchaseStream automatically delivers pending transactions
      // when we start listening. purchaseStream will trigger for any
      // unfinished transactions, and we handle them in _handlePurchaseUpdates.

      // No additional action needed - just wait a moment for the stream
      // to process any pending transactions
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('Pending transactions check completed');
    } catch (e) {
      debugPrint('Failed to handle pending transactions: $e');
    }
  }

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
          _handleCanceled(purchase);
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
    final transactionId = purchase.purchaseID ?? purchase.productID;

    debugPrint('========== _handlePurchase 开始 ==========');
    debugPrint('产品ID: ${purchase.productID}');
    debugPrint('交易ID: $transactionId');
    debugPrint('状态: ${purchase.status}');
    debugPrint('需要完成交易: ${purchase.pendingCompletePurchase}');

    // 检查是否是已完成的交易（持久化存储中）
    if (_completedTransactionIds.contains(transactionId)) {
      debugPrint('⚠️ 交易 $transactionId 已在持久化存储中标记为完成，直接完成交易');
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
          debugPrint('✅ 已完成的重复交易已处理');
        } catch (e) {
          debugPrint('❌ 完成重复交易失败: $e');
        }
      }
      return;
    }

    // 防止同一交易被重复处理（内存缓存）
    if (_processingTransactionIds.contains(transactionId)) {
      debugPrint('⚠️ 交易 $transactionId 正在处理中，跳过重复请求');
      return;
    }

    // 防止并发处理多个购买请求
    if (_isProcessingPurchase) {
      debugPrint('⚠️ 已有购买正在处理中，将此交易加入等待...');
      // 延迟后重试
      await Future.delayed(const Duration(milliseconds: 500));
      if (_processingTransactionIds.contains(transactionId)) {
        debugPrint('⚠️ 交易 $transactionId 已被处理，跳过');
        return;
      }
    }

    // 加锁
    _isProcessingPurchase = true;
    _processingTransactionIds.add(transactionId);
    _transactionIdTimestamps[transactionId] = DateTime.now();
    debugPrint('🔒 已锁定交易处理: $transactionId');

    try {
      debugPrint('步骤1: 开始后端验证...');
      // Verify with backend
      await _verifyWithBackend(purchase);
      debugPrint('步骤1: 后端验证成功');

      // ALWAYS complete the purchase after successful verification
      debugPrint('步骤2: 检查是否需要完成交易...');
      if (purchase.pendingCompletePurchase) {
        debugPrint('步骤2: 调用 completePurchase...');
        await _iap.completePurchase(purchase);
        debugPrint('步骤2: completePurchase 调用成功');
      } else {
        debugPrint('步骤2: 交易已完成，无需操作');
      }

      // 将交易ID保存到持久化存储，防止 App 重启后重复处理
      await _saveCompletedTransactionId(transactionId);

      // 清除持久化的购买上下文
      await _clearPurchaseContext();

      // Notify success (安全调用)
      debugPrint('步骤3: 调用 onPurchaseSuccess 回调');
      _safeCallSuccess(purchase);
      debugPrint('========== _handlePurchase 完成 ==========');
    } catch (e) {
      debugPrint('❌ _handlePurchase 失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');

      final errorMessage = e.toString();

      // Check if error is about duplicate purchase
      final isDuplicateError = errorMessage.contains('DUPLICATE_TRANSACTION') ||
                               errorMessage.contains('订单已存在') ||
                               errorMessage.contains('duplicate') ||
                               errorMessage.contains('already exists');

      // IMPORTANT: Complete the purchase to remove it from StoreKit queue
      debugPrint('尝试完成交易以避免卡住 (pendingCompletePurchase: ${purchase.pendingCompletePurchase})');
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
          debugPrint('✅ 交易已完成 (验证失败后)');
        } catch (completeError) {
          debugPrint('❌ 完成交易失败: $completeError');
        }
      }

      // For duplicate purchases, treat as success
      if (isDuplicateError) {
        debugPrint('========== 检测到重复交易 ==========');
        debugPrint('交易已在之前成功处理，完成当前交易以停止重试');
        // 将交易ID保存到持久化存储
        await _saveCompletedTransactionId(transactionId);
        await _clearPurchaseContext();
        // Notify success (安全调用)
        _safeCallSuccess(purchase);
        debugPrint('========== 重复交易处理完成 ==========');
      } else {
        // Notify error to UI (安全调用)
        debugPrint('通知 UI 错误');
        _safeCallError(purchase, errorMessage);
      }
      debugPrint('========== _handlePurchase 结束 (有错误) ==========');
    } finally {
      // 解锁
      _isProcessingPurchase = false;
      debugPrint('🔓 已解锁交易处理，交易ID $transactionId 已记录');
    }
  }

  /// 安全调用成功回调（捕获异常避免崩溃）
  void _safeCallSuccess(PurchaseDetails purchase) {
    try {
      if (onPurchaseSuccess != null) {
        onPurchaseSuccess?.call(purchase);
        debugPrint('onPurchaseSuccess 回调已执行');
      } else {
        debugPrint('⚠️ onPurchaseSuccess 回调为 null (可能是后台交易)');
      }
    } catch (e) {
      // 捕获回调异常，防止 Widget 销毁后调用 ref 导致崩溃
      debugPrint('⚠️ onPurchaseSuccess 回调执行出错 (可能是 Widget 已销毁): $e');
    }
  }

  /// 安全调用错误回调（捕获异常避免崩溃）
  void _safeCallError(PurchaseDetails purchase, String error) {
    try {
      onPurchaseError?.call(purchase, error);
    } catch (e) {
      debugPrint('⚠️ onPurchaseError 回调执行出错 (可能是 Widget 已销毁): $e');
    }
  }

  /// Handle purchase error
  Future<void> _handleError(PurchaseDetails purchase) async {
    final error = purchase.error?.message ?? 'Unknown error';
    debugPrint('========== 处理购买错误 ==========');
    debugPrint('产品ID: ${purchase.productID}');
    debugPrint('交易ID: ${purchase.purchaseID}');
    debugPrint('错误信息: $error');
    debugPrint('需要完成交易: ${purchase.pendingCompletePurchase}');

    // 完成交易以清理队列，防止堵塞后续购买
    if (purchase.pendingCompletePurchase) {
      try {
        debugPrint('完成错误的交易以清理队列...');
        await _iap.completePurchase(purchase);
        debugPrint('✅ 错误的交易已成功完成并清理');
      } catch (e) {
        debugPrint('❌ 完成错误交易时出错: $e');
      }
    }

    _safeCallError(purchase, error);
    debugPrint('========== 购买错误处理完成 ==========');
  }

  /// Handle canceled purchase
  Future<void> _handleCanceled(PurchaseDetails purchase) async {
    debugPrint('========== 处理取消的购买 ==========');
    debugPrint('产品ID: ${purchase.productID}');
    debugPrint('交易ID: ${purchase.purchaseID}');
    debugPrint('需要完成交易: ${purchase.pendingCompletePurchase}');

    // CRITICAL: Complete the canceled purchase to remove it from StoreKit's queue
    if (purchase.pendingCompletePurchase) {
      try {
        debugPrint('完成取消的交易以清理队列...');
        await _iap.completePurchase(purchase);
        debugPrint('✅ 取消的交易已成功完成并清理');
      } catch (e) {
        debugPrint('❌ 完成取消的交易时出错: $e');
      }
    } else {
      debugPrint('取消的交易已完成，无需操作');
    }

    // 通知 UI 购买已取消（安全调用）
    try {
      onPurchaseCanceled?.call();
    } catch (e) {
      debugPrint('⚠️ onPurchaseCanceled 回调执行出错: $e');
    }

    debugPrint('========== 取消购买处理完成 ==========');
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

    // 优先使用持久化的上下文，如果没有则使用空 map
    final context = await _loadPurchaseContext() ?? {};
    final platform = Platform.isIOS ? 'AppStore' : 'GooglePay';

    debugPrint('购买详情 - 产品ID: ${purchase.productID}, 平台: $platform');
    debugPrint('来源信息 - 分销商ID: ${context['distributorId']}, 口令ID: ${context['sourcePasscodeId']}');
    debugPrint('来源信息 - 书籍ID: ${context['sourceBookId']}, 入口: ${context['sourceEntry']}');

    // 重试逻辑
    const int maxRetries = 3;
    int retryCount = 0;
    Exception? lastError;

    while (retryCount < maxRetries) {
      try {
        debugPrint('调用后端验证接口... (尝试 ${retryCount + 1}/$maxRetries)');
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
        return; // 成功，直接返回
      } catch (e) {
        lastError = e as Exception;
        retryCount++;
        debugPrint('后端验证失败 (尝试 $retryCount/$maxRetries): $e');

        // 如果是重复交易错误，不需要重试
        final errorMessage = e.toString();
        if (errorMessage.contains('DUPLICATE_TRANSACTION') ||
            errorMessage.contains('订单已存在')) {
          debugPrint('检测到重复交易错误，不进行重试');
          rethrow;
        }

        // 如果还有重试机会，等待后重试
        if (retryCount < maxRetries) {
          final delay = Duration(seconds: retryCount * 2); // 指数退避
          debugPrint('等待 ${delay.inSeconds} 秒后重试...');
          await Future.delayed(delay);
        }
      }
    }

    // 所有重试都失败了
    debugPrint('========== 购买验证失败（已重试 $maxRetries 次）==========');
    throw lastError ?? Exception('验证失败');
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
    _isProcessingPurchase = false;
    _processingTransactionIds.clear();
    _transactionIdTimestamps.clear();
  }
}
