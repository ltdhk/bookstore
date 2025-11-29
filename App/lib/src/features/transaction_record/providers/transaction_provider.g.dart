// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for transaction records (orders)

@ProviderFor(TransactionRecords)
const transactionRecordsProvider = TransactionRecordsProvider._();

/// Provider for transaction records (orders)
final class TransactionRecordsProvider
    extends $AsyncNotifierProvider<TransactionRecords, List<Order>> {
  /// Provider for transaction records (orders)
  const TransactionRecordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRecordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRecordsHash();

  @$internal
  @override
  TransactionRecords create() => TransactionRecords();
}

String _$transactionRecordsHash() =>
    r'4b0c78a91d8f4ac85c9dffdcc56b6c988a03c822';

/// Provider for transaction records (orders)

abstract class _$TransactionRecords extends $AsyncNotifier<List<Order>> {
  FutureOr<List<Order>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for getting a single order by ID

@ProviderFor(orderDetail)
const orderDetailProvider = OrderDetailFamily._();

/// Provider for getting a single order by ID

final class OrderDetailProvider
    extends $FunctionalProvider<AsyncValue<Order>, Order, FutureOr<Order>>
    with $FutureModifier<Order>, $FutureProvider<Order> {
  /// Provider for getting a single order by ID
  const OrderDetailProvider._({
    required OrderDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Order> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Order> create(Ref ref) {
    final argument = this.argument as int;
    return orderDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailHash() => r'157f03aa77299b2e14cb787b781769b383b595c8';

/// Provider for getting a single order by ID

final class OrderDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Order>, int> {
  const OrderDetailFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a single order by ID

  OrderDetailProvider call(int orderId) =>
      OrderDetailProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderDetailProvider';
}
