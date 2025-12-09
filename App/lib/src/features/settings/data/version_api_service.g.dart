// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(versionApiService)
const versionApiServiceProvider = VersionApiServiceProvider._();

final class VersionApiServiceProvider
    extends
        $FunctionalProvider<
          VersionApiService,
          VersionApiService,
          VersionApiService
        >
    with $Provider<VersionApiService> {
  const VersionApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionApiServiceHash();

  @$internal
  @override
  $ProviderElement<VersionApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VersionApiService create(Ref ref) {
    return versionApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VersionApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VersionApiService>(value),
    );
  }
}

String _$versionApiServiceHash() => r'2cf2573e94fd000dff994ef510e59b7bacd54488';
