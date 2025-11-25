// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advertisements_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for home banner advertisements

@ProviderFor(homeBannerAdvertisements)
const homeBannerAdvertisementsProvider = HomeBannerAdvertisementsProvider._();

/// Provider for home banner advertisements

final class HomeBannerAdvertisementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Advertisement>>,
          List<Advertisement>,
          FutureOr<List<Advertisement>>
        >
    with
        $FutureModifier<List<Advertisement>>,
        $FutureProvider<List<Advertisement>> {
  /// Provider for home banner advertisements
  const HomeBannerAdvertisementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBannerAdvertisementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannerAdvertisementsHash();

  @$internal
  @override
  $FutureProviderElement<List<Advertisement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Advertisement>> create(Ref ref) {
    return homeBannerAdvertisements(ref);
  }
}

String _$homeBannerAdvertisementsHash() =>
    r'974d6f06f55883e0d12baa2d912ce66a4754cc22';
