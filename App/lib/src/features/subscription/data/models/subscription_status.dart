import 'package:json_annotation/json_annotation.dart';

part 'subscription_status.g.dart';

@JsonSerializable()
class SubscriptionStatus {
  final String subscriptionStatus;
  final DateTime? subscriptionEndDate;
  final String? subscriptionPlanType;
  final bool isSvip;
  final int? orderId;
  final String? orderNo;
  final double? amount;
  final String? platform;
  final DateTime? subscriptionStartDate;
  final bool? isAutoRenew;

  SubscriptionStatus({
    required this.subscriptionStatus,
    this.subscriptionEndDate,
    this.subscriptionPlanType,
    required this.isSvip,
    this.orderId,
    this.orderNo,
    this.amount,
    this.platform,
    this.subscriptionStartDate,
    this.isAutoRenew,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionStatusToJson(this);

  /// Check if subscription is active
  bool get isActive {
    return subscriptionStatus.toLowerCase() == 'active' && isSvip;
  }

  /// Check if subscription is expired
  bool get isExpired {
    if (subscriptionEndDate == null) return true;
    return DateTime.now().isAfter(subscriptionEndDate!);
  }

  /// Get remaining days
  int get remainingDays {
    if (subscriptionEndDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(subscriptionEndDate!)) return 0;
    return subscriptionEndDate!.difference(now).inDays;
  }

  /// Get status display string
  String get statusDisplay {
    switch (subscriptionStatus.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'none':
        return 'No Subscription';
      default:
        return subscriptionStatus;
    }
  }

  /// Get plan type display string
  String get planTypeDisplay {
    if (subscriptionPlanType == null) return '';
    switch (subscriptionPlanType!.toLowerCase()) {
      case 'monthly':
        return 'Monthly Plan';
      case 'quarterly':
        return 'Quarterly Plan';
      case 'yearly':
        return 'Annual Plan';
      default:
        return subscriptionPlanType!;
    }
  }
}
