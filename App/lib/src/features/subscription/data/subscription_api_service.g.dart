// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subscriptionApiService)
const subscriptionApiServiceProvider = SubscriptionApiServiceProvider._();

final class SubscriptionApiServiceProvider
    extends
        $FunctionalProvider<
          SubscriptionApiService,
          SubscriptionApiService,
          SubscriptionApiService
        >
    with $Provider<SubscriptionApiService> {
  const SubscriptionApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionApiServiceHash();

  @$internal
  @override
  $ProviderElement<SubscriptionApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubscriptionApiService create(Ref ref) {
    return subscriptionApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionApiService>(value),
    );
  }
}

String _$subscriptionApiServiceHash() =>
    r'2c6e4b3ac2ed3ac81fd4d583bd34cf3f9beb0e74';
