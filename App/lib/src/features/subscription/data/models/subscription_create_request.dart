import 'package:json_annotation/json_annotation.dart';

part 'subscription_create_request.g.dart';

@JsonSerializable()
class SubscriptionCreateRequest {
  final String productId;
  final String platform;
  final int? distributorId;
  final int? sourcePasscodeId;
  final int? sourceBookId;
  final String? sourceEntry;
  final String? receiptData;
  final String? purchaseToken;

  SubscriptionCreateRequest({
    required this.productId,
    required this.platform,
    this.distributorId,
    this.sourcePasscodeId,
    this.sourceBookId,
    this.sourceEntry,
    this.receiptData,
    this.purchaseToken,
  });

  factory SubscriptionCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionCreateRequestToJson(this);
}
