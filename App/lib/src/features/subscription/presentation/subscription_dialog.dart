import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:novelpop/src/features/subscription/data/models/subscription_product.dart';
import 'package:novelpop/src/features/subscription/providers/subscription_provider.dart';
import 'package:novelpop/src/features/passcode/providers/passcode_provider.dart';
import 'package:novelpop/src/features/passcode/data/passcode_api_service.dart';
import 'package:novelpop/src/services/iap/platform_product_config.dart';

class SubscriptionDialog extends ConsumerStatefulWidget {
  final int? sourceBookId;
  final String sourceEntry;

  const SubscriptionDialog({
    super.key,
    this.sourceBookId,
    this.sourceEntry = 'reader',
  });

  @override
  ConsumerState<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends ConsumerState<SubscriptionDialog> {
  String? _selectedProductId;
  String? _selectedPlanType; // 'weekly', 'monthly', 'yearly'
  bool _isProcessing = false;
  Map<String, ProductDetails>? _iapProducts;
  bool _iapAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    try {
      final iapService = ref.read(inAppPurchaseServiceProvider);
      final available = await iapService.initialize();

      if (available) {
        // Load available products from store
        final productIds = PlatformProductConfig.getAllPlatformProductIds();
        final products = await iapService.queryProducts(productIds);

        if (mounted) {
          setState(() {
            _iapAvailable = true;
            _iapProducts = {
              for (var product in products) product.id: product
            };
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize IAP: $e');
    }
  }

  @override
  void dispose() {
    // IAP service will handle its own disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final productsAsync = ref.watch(groupedSubscriptionProductsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: productsAsync.when(
          loading: () => const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load subscriptions',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          data: (products) => _buildContent(context, products, isDark),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, SubscriptionProduct> products,
    bool isDark,
  ) {
    final weekly = products['weekly'];
    final monthly = products['monthly'];
    final yearly = products['yearly'];

    // Calculate savings based on weekly price
    final weeklyPrice = weekly?.price ?? 19.9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SVIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Choose Your Plan',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Subscription options
        if (weekly != null)
          _buildSubscriptionOption(
            weekly,
            'Weekly',
            null,
            isDark,
            false,
          ),
        if (monthly != null) ...[
          const SizedBox(height: 12),
          _buildSubscriptionOption(
            monthly,
            'Monthly',
            monthly.getSavingsPercentage(weeklyPrice * 4),
            isDark,
            false,
          ),
        ],
        if (yearly != null) ...[
          const SizedBox(height: 12),
          _buildSubscriptionOption(
            yearly,
            'Annual',
            yearly.getSavingsPercentage(weeklyPrice * 52),
            isDark,
            true,
          ),
        ],
        const SizedBox(height: 24),

        // Subscribe button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessing || _selectedProductId == null
                ? null
                : () => _handleSubscribe(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              disabledBackgroundColor: Colors.grey[400],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Terms
        Text(
          'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription will auto-renew unless cancelled.',
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubscriptionOption(
    SubscriptionProduct product,
    String displayName,
    double? savingsPercentage,
    bool isDark,
    bool isRecommended,
  ) {
    final isSelected = _selectedProductId == product.productId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedProductId = product.productId;
          _selectedPlanType = product.planType; // Store plan type for IAP
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE91E63)
                : isRecommended
                    ? const Color(0xFFFFD700)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE91E63)
                      : isDark
                          ? Colors.grey[600]!
                          : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Plan info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Best Value',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.durationDisplay,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Price info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceDisplay,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFFE91E63)
                        : isDark
                            ? Colors.white
                            : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (savingsPercentage != null && savingsPercentage > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Save ${savingsPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscribe(BuildContext context) async {
    if (_selectedProductId == null || _selectedPlanType == null) return;

    // Check if IAP is available and products are loaded
    if (!_iapAvailable || _iapProducts == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('In-app purchase is not available on this device'),
            backgroundColor: Colors.red[400],
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final platform = getCurrentPlatform();

      // Get platform-specific product ID
      final platformProductId = PlatformProductConfig.getPlatformProductId(_selectedPlanType!);

      // Get ProductDetails from IAP
      final productDetails = _iapProducts![platformProductId];
      if (productDetails == null) {
        throw Exception('Product not found: $platformProductId');
      }

      // Get passcode context if available and matches current book
      final passcodeContext = ref.read(activePasscodeContextProvider);
      final int? passcodeId = (passcodeContext != null &&
              widget.sourceBookId != null &&
              passcodeContext.bookId == widget.sourceBookId)
          ? passcodeContext.passcodeId
          : null;
      final int? distributorId = (passcodeContext != null &&
              widget.sourceBookId != null &&
              passcodeContext.bookId == widget.sourceBookId)
          ? passcodeContext.distributorId
          : null;

      // Setup IAP service callbacks
      final iapService = ref.read(inAppPurchaseServiceProvider);

      iapService.onPurchaseSuccess = (purchase) async {
        debugPrint('Purchase successful: ${purchase.productID}');

        // Track 'sub' action if subscription was via passcode
        if (passcodeId != null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            final userIdStr = prefs.getString('user_id');
            final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
            final passcodeApiService = ref.read(passcodeApiServiceProvider);
            await passcodeApiService.trackSubscription(passcodeId: passcodeId, userId: userId);
            debugPrint('Passcode sub action tracked: $passcodeId, userId: $userId');
          } catch (e) {
            debugPrint('Failed to track passcode sub action: $e');
          }
        }

        // Refresh subscription status
        ref.invalidate(subscriptionStatusProvider);
        ref.invalidate(subscriptionValidProvider);

        if (context.mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription successful! You are now a SVIP member.'),
              backgroundColor: Color(0xFF4CAF50),
              duration: Duration(seconds: 3),
            ),
          );
        }

        setState(() {
          _isProcessing = false;
        });
      };

      iapService.onPurchaseError = (purchase, error) {
        debugPrint('Purchase error: $error');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Subscription failed: $error'),
              backgroundColor: Colors.red[400],
              duration: const Duration(seconds: 3),
            ),
          );
        }

        setState(() {
          _isProcessing = false;
        });
      };

      iapService.onPurchasePending = () {
        debugPrint('Purchase pending...');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase is pending... Please wait.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      };

      // Initiate the purchase
      await iapService.purchaseProduct(
        productDetails,
        platform: platform,
        productId: _selectedProductId!,
        distributorId: distributorId,
        sourcePasscodeId: passcodeId,
        sourceBookId: widget.sourceBookId,
        sourceEntry: widget.sourceEntry,
      );
    } catch (e) {
      debugPrint('Failed to initiate purchase: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start purchase: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
