// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passcode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Global passcode context provider.
/// Stores the currently active passcode context for tracking.
/// This is kept alive throughout the app session (memory only, not persisted).

@ProviderFor(ActivePasscodeContext)
const activePasscodeContextProvider = ActivePasscodeContextProvider._();

/// Global passcode context provider.
/// Stores the currently active passcode context for tracking.
/// This is kept alive throughout the app session (memory only, not persisted).
final class ActivePasscodeContextProvider
    extends $NotifierProvider<ActivePasscodeContext, PasscodeContext?> {
  /// Global passcode context provider.
  /// Stores the currently active passcode context for tracking.
  /// This is kept alive throughout the app session (memory only, not persisted).
  const ActivePasscodeContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePasscodeContextProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePasscodeContextHash();

  @$internal
  @override
  ActivePasscodeContext create() => ActivePasscodeContext();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasscodeContext? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasscodeContext?>(value),
    );
  }
}

String _$activePasscodeContextHash() =>
    r'a0c1ed306566708c874588b5939548d1a95941b1';

/// Global passcode context provider.
/// Stores the currently active passcode context for tracking.
/// This is kept alive throughout the app session (memory only, not persisted).

abstract class _$ActivePasscodeContext extends $Notifier<PasscodeContext?> {
  PasscodeContext? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PasscodeContext?, PasscodeContext?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PasscodeContext?, PasscodeContext?>,
              PasscodeContext?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider to track passcode usage when entering reader

@ProviderFor(PasscodeUsageTracker)
const passcodeUsageTrackerProvider = PasscodeUsageTrackerProvider._();

/// Provider to track passcode usage when entering reader
final class PasscodeUsageTrackerProvider
    extends $NotifierProvider<PasscodeUsageTracker, bool> {
  /// Provider to track passcode usage when entering reader
  const PasscodeUsageTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passcodeUsageTrackerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passcodeUsageTrackerHash();

  @$internal
  @override
  PasscodeUsageTracker create() => PasscodeUsageTracker();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$passcodeUsageTrackerHash() =>
    r'16dc9f507319b4b4db89b4112bede8df766f3f72';

/// Provider to track passcode usage when entering reader

abstract class _$PasscodeUsageTracker extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
