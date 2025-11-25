// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionProduct _$SubscriptionProductFromJson(Map<String, dynamic> json) =>
    SubscriptionProduct(
      id: (json['id'] as num).toInt(),
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      planType: json['planType'] as String,
      durationDays: (json['durationDays'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      platform: json['platform'] as String,
      appleProductId: json['appleProductId'] as String?,
      googleProductId: json['googleProductId'] as String?,
      isActive: json['isActive'] as bool,
      sortOrder: (json['sortOrder'] as num).toInt(),
      description: json['description'] as String?,
      features: _featuresFromJson(json['features']),
    );

Map<String, dynamic> _$SubscriptionProductToJson(
  SubscriptionProduct instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'productName': instance.productName,
  'planType': instance.planType,
  'durationDays': instance.durationDays,
  'price': instance.price,
  'currency': instance.currency,
  'platform': instance.platform,
  'appleProductId': instance.appleProductId,
  'googleProductId': instance.googleProductId,
  'isActive': instance.isActive,
  'sortOrder': instance.sortOrder,
  'description': instance.description,
  'features': instance.features,
};
