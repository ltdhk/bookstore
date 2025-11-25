// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) =>
    SubscriptionStatus(
      subscriptionStatus: json['subscriptionStatus'] as String,
      subscriptionEndDate: json['subscriptionEndDate'] == null
          ? null
          : DateTime.parse(json['subscriptionEndDate'] as String),
      subscriptionPlanType: json['subscriptionPlanType'] as String?,
      isSvip: json['isSvip'] as bool,
      orderId: (json['orderId'] as num?)?.toInt(),
      orderNo: json['orderNo'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      platform: json['platform'] as String?,
      subscriptionStartDate: json['subscriptionStartDate'] == null
          ? null
          : DateTime.parse(json['subscriptionStartDate'] as String),
      isAutoRenew: json['isAutoRenew'] as bool?,
    );

Map<String, dynamic> _$SubscriptionStatusToJson(
  SubscriptionStatus instance,
) => <String, dynamic>{
  'subscriptionStatus': instance.subscriptionStatus,
  'subscriptionEndDate': instance.subscriptionEndDate?.toIso8601String(),
  'subscriptionPlanType': instance.subscriptionPlanType,
  'isSvip': instance.isSvip,
  'orderId': instance.orderId,
  'orderNo': instance.orderNo,
  'amount': instance.amount,
  'platform': instance.platform,
  'subscriptionStartDate': instance.subscriptionStartDate?.toIso8601String(),
  'isAutoRenew': instance.isAutoRenew,
};
