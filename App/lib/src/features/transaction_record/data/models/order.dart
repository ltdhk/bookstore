import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int id;
  final int userId;
  final int? distributorId;
  final int? sourcePasscodeId;
  final String orderNo;
  final double amount;
  final String status; // Pending, Paid, Refunded
  final String platform; // AppStore, GooglePay
  final String productId;
  final String? orderType; // onetime, subscription
  final String? subscriptionPeriod; // monthly, quarterly, yearly
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool? isAutoRenew;
  final DateTime? cancelDate;
  final String? cancelReason;
  final String? originalTransactionId;
  final String? platformTransactionId;
  final String? purchaseToken;
  final String? receiptData;
  final int? sourceBookId;
  final String? sourceEntry; // profile, reader
  final DateTime createTime;
  final DateTime? updateTime;

  Order({
    required this.id,
    required this.userId,
    this.distributorId,
    this.sourcePasscodeId,
    required this.orderNo,
    required this.amount,
    required this.status,
    required this.platform,
    required this.productId,
    this.orderType,
    this.subscriptionPeriod,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isAutoRenew,
    this.cancelDate,
    this.cancelReason,
    this.originalTransactionId,
    this.platformTransactionId,
    this.purchaseToken,
    this.receiptData,
    this.sourceBookId,
    this.sourceEntry,
    required this.createTime,
    this.updateTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Helper method to get status display text
  String get statusDisplay {
    switch (status) {
      case 'Pending':
        return 'Pending';
      case 'Paid':
        return 'Paid';
      case 'Refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  // Helper method to get subscription period display text
  String get subscriptionPeriodDisplay {
    switch (subscriptionPeriod) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'yearly':
        return 'Yearly';
      default:
        return subscriptionPeriod ?? 'One-time';
    }
  }
}
