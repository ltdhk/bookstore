// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for reading history items

@ProviderFor(ReadingHistory)
const readingHistoryProvider = ReadingHistoryProvider._();

/// Provider for reading history items
final class ReadingHistoryProvider
    extends $AsyncNotifierProvider<ReadingHistory, List<ReadingHistoryItem>> {
  /// Provider for reading history items
  const ReadingHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingHistoryHash();

  @$internal
  @override
  ReadingHistory create() => ReadingHistory();
}

String _$readingHistoryHash() => r'2b850e742a1a92658dbdc33d9e888eed4e6e448d';

/// Provider for reading history items

abstract class _$ReadingHistory
    extends $AsyncNotifier<List<ReadingHistoryItem>> {
  FutureOr<List<ReadingHistoryItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ReadingHistoryItem>>,
              List<ReadingHistoryItem>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ReadingHistoryItem>>,
                List<ReadingHistoryItem>
              >,
              AsyncValue<List<ReadingHistoryItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for reading history count

@ProviderFor(readingHistoryCount)
const readingHistoryCountProvider = ReadingHistoryCountProvider._();

/// Provider for reading history count

final class ReadingHistoryCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider for reading history count
  const ReadingHistoryCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingHistoryCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingHistoryCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return readingHistoryCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$readingHistoryCountHash() =>
    r'609a2812c4d2db65615cb89bb1c46e876f48c7fb';
