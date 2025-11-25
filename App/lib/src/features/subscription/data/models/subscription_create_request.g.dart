// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionCreateRequest _$SubscriptionCreateRequestFromJson(
  Map<String, dynamic> json,
) => SubscriptionCreateRequest(
  productId: json['productId'] as String,
  platform: json['platform'] as String,
  distributorId: (json['distributorId'] as num?)?.toInt(),
  sourcePasscodeId: (json['sourcePasscodeId'] as num?)?.toInt(),
  sourceBookId: (json['sourceBookId'] as num?)?.toInt(),
  sourceEntry: json['sourceEntry'] as String?,
  receiptData: json['receiptData'] as String?,
  purchaseToken: json['purchaseToken'] as String?,
);

Map<String, dynamic> _$SubscriptionCreateRequestToJson(
  SubscriptionCreateRequest instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'platform': instance.platform,
  'distributorId': instance.distributorId,
  'sourcePasscodeId': instance.sourcePasscodeId,
  'sourceBookId': instance.sourceBookId,
  'sourceEntry': instance.sourceEntry,
  'receiptData': instance.receiptData,
  'purchaseToken': instance.purchaseToken,
};
