// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passcode_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(passcodeApiService)
const passcodeApiServiceProvider = PasscodeApiServiceProvider._();

final class PasscodeApiServiceProvider
    extends
        $FunctionalProvider<
          PasscodeApiService,
          PasscodeApiService,
          PasscodeApiService
        >
    with $Provider<PasscodeApiService> {
  const PasscodeApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passcodeApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passcodeApiServiceHash();

  @$internal
  @override
  $ProviderElement<PasscodeApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PasscodeApiService create(Ref ref) {
    return passcodeApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasscodeApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasscodeApiService>(value),
    );
  }
}

String _$passcodeApiServiceHash() =>
    r'c318bf02e6b3de9e73ef870dddfb9c9a9b394504';
