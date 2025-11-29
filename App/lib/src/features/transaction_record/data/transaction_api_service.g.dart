// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactionApiService)
const transactionApiServiceProvider = TransactionApiServiceProvider._();

final class TransactionApiServiceProvider
    extends
        $FunctionalProvider<
          TransactionApiService,
          TransactionApiService,
          TransactionApiService
        >
    with $Provider<TransactionApiService> {
  const TransactionApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionApiServiceHash();

  @$internal
  @override
  $ProviderElement<TransactionApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionApiService create(Ref ref) {
    return transactionApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionApiService>(value),
    );
  }
}

String _$transactionApiServiceHash() =>
    r'ec27019f041ca5d011c8bb91d64bd3d665b3776b';
