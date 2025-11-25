import 'package:json_annotation/json_annotation.dart';

part 'subscription_product.g.dart';

@JsonSerializable()
class SubscriptionProduct {
  final int id;
  final String productId;
  final String productName;
  final String planType;
  final int durationDays;
  final double price;
  final String currency;
  final String platform;
  final String? appleProductId;
  final String? googleProductId;
  final bool isActive;
  final int sortOrder;
  final String? description;
  @JsonKey(fromJson: _featuresFromJson)
  final List<String>? features;

  SubscriptionProduct({
    required this.id,
    required this.productId,
    required this.productName,
    required this.planType,
    required this.durationDays,
    required this.price,
    required this.currency,
    required this.platform,
    this.appleProductId,
    this.googleProductId,
    required this.isActive,
    required this.sortOrder,
    this.description,
    this.features,
  });

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionProductFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionProductToJson(this);

  /// Get display name for plan type
  String get planTypeDisplay {
    switch (planType.toLowerCase()) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Annual';
      default:
        return planType;
    }
  }

  /// Get duration display string
  String get durationDisplay {
    if (durationDays == 30) return '1 Month';
    if (durationDays == 90) return '3 Months';
    if (durationDays == 365) return '12 Months';
    return '$durationDays Days';
  }

  /// Get price display string
  String get priceDisplay {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Calculate savings percentage compared to monthly plan
  double getSavingsPercentage(double monthlyPrice) {
    if (durationDays == 30) return 0;
    final monthlyEquivalent = (price / (durationDays / 30));
    final savings = ((monthlyPrice - monthlyEquivalent) / monthlyPrice) * 100;
    return savings > 0 ? savings : 0;
  }
}

/// Custom JSON converter for features field
/// Backend might return a string instead of a list
List<String>? _featuresFromJson(dynamic json) {
  if (json == null) return null;
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  if (json is String) {
    // If it's a string, return it as a single-item list
    return [json];
  }
  return null;
}
