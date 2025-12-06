// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for InAppPurchaseService
/// 使用 keepAlive: true 确保 IAP Service 不会被自动销毁
/// 这对于处理后台交易和 App 生命周期变化至关重要

@ProviderFor(inAppPurchaseService)
const inAppPurchaseServiceProvider = InAppPurchaseServiceProvider._();

/// Provider for InAppPurchaseService
/// 使用 keepAlive: true 确保 IAP Service 不会被自动销毁
/// 这对于处理后台交易和 App 生命周期变化至关重要

final class InAppPurchaseServiceProvider
    extends
        $FunctionalProvider<
          InAppPurchaseService,
          InAppPurchaseService,
          InAppPurchaseService
        >
    with $Provider<InAppPurchaseService> {
  /// Provider for InAppPurchaseService
  /// 使用 keepAlive: true 确保 IAP Service 不会被自动销毁
  /// 这对于处理后台交易和 App 生命周期变化至关重要
  const InAppPurchaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inAppPurchaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inAppPurchaseServiceHash();

  @$internal
  @override
  $ProviderElement<InAppPurchaseService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InAppPurchaseService create(Ref ref) {
    return inAppPurchaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InAppPurchaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InAppPurchaseService>(value),
    );
  }
}

String _$inAppPurchaseServiceHash() =>
    r'7c56cafefcc0e2f2aa09fae045f41d03e558fc20';

/// Provider for subscription products list

@ProviderFor(subscriptionProducts)
const subscriptionProductsProvider = SubscriptionProductsFamily._();

/// Provider for subscription products list

final class SubscriptionProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SubscriptionProduct>>,
          List<SubscriptionProduct>,
          FutureOr<List<SubscriptionProduct>>
        >
    with
        $FutureModifier<List<SubscriptionProduct>>,
        $FutureProvider<List<SubscriptionProduct>> {
  /// Provider for subscription products list
  const SubscriptionProductsProvider._({
    required SubscriptionProductsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'subscriptionProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$subscriptionProductsHash();

  @override
  String toString() {
    return r'subscriptionProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SubscriptionProduct>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SubscriptionProduct>> create(Ref ref) {
    final argument = this.argument as String?;
    return subscriptionProducts(ref, platform: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SubscriptionProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subscriptionProductsHash() =>
    r'7196235b01f2a021a0f1752d34de9b1d5563684c';

/// Provider for subscription products list

final class SubscriptionProductsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SubscriptionProduct>>,
          String?
        > {
  const SubscriptionProductsFamily._()
    : super(
        retry: null,
        name: r'subscriptionProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for subscription products list

  SubscriptionProductsProvider call({String? platform}) =>
      SubscriptionProductsProvider._(argument: platform, from: this);

  @override
  String toString() => r'subscriptionProductsProvider';
}

/// Provider for current user subscription status

@ProviderFor(subscriptionStatus)
const subscriptionStatusProvider = SubscriptionStatusProvider._();

/// Provider for current user subscription status

final class SubscriptionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionStatus>,
          SubscriptionStatus,
          FutureOr<SubscriptionStatus>
        >
    with
        $FutureModifier<SubscriptionStatus>,
        $FutureProvider<SubscriptionStatus> {
  /// Provider for current user subscription status
  const SubscriptionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionStatusHash();

  @$internal
  @override
  $FutureProviderElement<SubscriptionStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionStatus> create(Ref ref) {
    return subscriptionStatus(ref);
  }
}

String _$subscriptionStatusHash() =>
    r'9bdad7558af472e1f0e91dd1c939bd01dfb20e92';

/// Provider for subscription validity

@ProviderFor(subscriptionValid)
const subscriptionValidProvider = SubscriptionValidProvider._();

/// Provider for subscription validity

final class SubscriptionValidProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for subscription validity
  const SubscriptionValidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionValidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionValidHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return subscriptionValid(ref);
  }
}

String _$subscriptionValidHash() => r'e66268a715c9f8b24263b7b66eb43aee549b9314';

/// Provider for platform-specific subscription products

@ProviderFor(platformSubscriptionProducts)
const platformSubscriptionProductsProvider =
    PlatformSubscriptionProductsProvider._();

/// Provider for platform-specific subscription products

final class PlatformSubscriptionProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SubscriptionProduct>>,
          List<SubscriptionProduct>,
          FutureOr<List<SubscriptionProduct>>
        >
    with
        $FutureModifier<List<SubscriptionProduct>>,
        $FutureProvider<List<SubscriptionProduct>> {
  /// Provider for platform-specific subscription products
  const PlatformSubscriptionProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'platformSubscriptionProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$platformSubscriptionProductsHash();

  @$internal
  @override
  $FutureProviderElement<List<SubscriptionProduct>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SubscriptionProduct>> create(Ref ref) {
    return platformSubscriptionProducts(ref);
  }
}

String _$platformSubscriptionProductsHash() =>
    r'b9e9d78c070dc40d27abcbad4363361cde165400';

/// Provider for grouped subscription products (monthly, quarterly, yearly)

@ProviderFor(groupedSubscriptionProducts)
const groupedSubscriptionProductsProvider =
    GroupedSubscriptionProductsProvider._();

/// Provider for grouped subscription products (monthly, quarterly, yearly)

final class GroupedSubscriptionProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, SubscriptionProduct>>,
          Map<String, SubscriptionProduct>,
          FutureOr<Map<String, SubscriptionProduct>>
        >
    with
        $FutureModifier<Map<String, SubscriptionProduct>>,
        $FutureProvider<Map<String, SubscriptionProduct>> {
  /// Provider for grouped subscription products (monthly, quarterly, yearly)
  const GroupedSubscriptionProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupedSubscriptionProductsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupedSubscriptionProductsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, SubscriptionProduct>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, SubscriptionProduct>> create(Ref ref) {
    return groupedSubscriptionProducts(ref);
  }
}

String _$groupedSubscriptionProductsHash() =>
    r'db1ea18b8ae24354153d3b7dd1b79b9604dc8361';
