// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertisement_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(advertisementApiService)
const advertisementApiServiceProvider = AdvertisementApiServiceProvider._();

final class AdvertisementApiServiceProvider
    extends
        $FunctionalProvider<
          AdvertisementApiService,
          AdvertisementApiService,
          AdvertisementApiService
        >
    with $Provider<AdvertisementApiService> {
  const AdvertisementApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'advertisementApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$advertisementApiServiceHash();

  @$internal
  @override
  $ProviderElement<AdvertisementApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdvertisementApiService create(Ref ref) {
    return advertisementApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdvertisementApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdvertisementApiService>(value),
    );
  }
}

String _$advertisementApiServiceHash() =>
    r'567ed98c1311ba95ce7df26eb9e489e51209ce3c';
