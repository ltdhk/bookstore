// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for current app version info

@ProviderFor(packageInfo)
const packageInfoProvider = PackageInfoProvider._();

/// Provider for current app version info

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  /// Provider for current app version info
  const PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'e85c18fc1df698cf58e72da2ff3d20b5e68db434';

/// Provider for checking version update

@ProviderFor(VersionCheck)
const versionCheckProvider = VersionCheckProvider._();

/// Provider for checking version update
final class VersionCheckProvider
    extends $AsyncNotifierProvider<VersionCheck, VersionInfo?> {
  /// Provider for checking version update
  const VersionCheckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'versionCheckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$versionCheckHash();

  @$internal
  @override
  VersionCheck create() => VersionCheck();
}

String _$versionCheckHash() => r'249cf14eddbd956ab84e269fb256450ee66e639c';

/// Provider for checking version update

abstract class _$VersionCheck extends $AsyncNotifier<VersionInfo?> {
  FutureOr<VersionInfo?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<VersionInfo?>, VersionInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VersionInfo?>, VersionInfo?>,
              AsyncValue<VersionInfo?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
