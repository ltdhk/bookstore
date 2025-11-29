// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  distributorId: (json['distributorId'] as num?)?.toInt(),
  sourcePasscodeId: (json['sourcePasscodeId'] as num?)?.toInt(),
  orderNo: json['orderNo'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  platform: json['platform'] as String,
  productId: json['productId'] as String,
  orderType: json['orderType'] as String?,
  subscriptionPeriod: json['subscriptionPeriod'] as String?,
  subscriptionStartDate: json['subscriptionStartDate'] == null
      ? null
      : DateTime.parse(json['subscriptionStartDate'] as String),
  subscriptionEndDate: json['subscriptionEndDate'] == null
      ? null
      : DateTime.parse(json['subscriptionEndDate'] as String),
  isAutoRenew: json['isAutoRenew'] as bool?,
  cancelDate: json['cancelDate'] == null
      ? null
      : DateTime.parse(json['cancelDate'] as String),
  cancelReason: json['cancelReason'] as String?,
  originalTransactionId: json['originalTransactionId'] as String?,
  platformTransactionId: json['platformTransactionId'] as String?,
  purchaseToken: json['purchaseToken'] as String?,
  receiptData: json['receiptData'] as String?,
  sourceBookId: (json['sourceBookId'] as num?)?.toInt(),
  sourceEntry: json['sourceEntry'] as String?,
  createTime: DateTime.parse(json['createTime'] as String),
  updateTime: json['updateTime'] == null
      ? null
      : DateTime.parse(json['updateTime'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'distributorId': instance.distributorId,
  'sourcePasscodeId': instance.sourcePasscodeId,
  'orderNo': instance.orderNo,
  'amount': instance.amount,
  'status': instance.status,
  'platform': instance.platform,
  'productId': instance.productId,
  'orderType': instance.orderType,
  'subscriptionPeriod': instance.subscriptionPeriod,
  'subscriptionStartDate': instance.subscriptionStartDate?.toIso8601String(),
  'subscriptionEndDate': instance.subscriptionEndDate?.toIso8601String(),
  'isAutoRenew': instance.isAutoRenew,
  'cancelDate': instance.cancelDate?.toIso8601String(),
  'cancelReason': instance.cancelReason,
  'originalTransactionId': instance.originalTransactionId,
  'platformTransactionId': instance.platformTransactionId,
  'purchaseToken': instance.purchaseToken,
  'receiptData': instance.receiptData,
  'sourceBookId': instance.sourceBookId,
  'sourceEntry': instance.sourceEntry,
  'createTime': instance.createTime.toIso8601String(),
  'updateTime': instance.updateTime?.toIso8601String(),
};
