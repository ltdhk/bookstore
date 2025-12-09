// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_history_local_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingHistoryLocalStorage)
const readingHistoryLocalStorageProvider =
    ReadingHistoryLocalStorageProvider._();

final class ReadingHistoryLocalStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingHistoryLocalStorage>,
          ReadingHistoryLocalStorage,
          FutureOr<ReadingHistoryLocalStorage>
        >
    with
        $FutureModifier<ReadingHistoryLocalStorage>,
        $FutureProvider<ReadingHistoryLocalStorage> {
  const ReadingHistoryLocalStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingHistoryLocalStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingHistoryLocalStorageHash();

  @$internal
  @override
  $FutureProviderElement<ReadingHistoryLocalStorage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingHistoryLocalStorage> create(Ref ref) {
    return readingHistoryLocalStorage(ref);
  }
}

String _$readingHistoryLocalStorageHash() =>
    r'ac2be8ef2c6af5b0e1d8f32eee3321ff78b4c092';
