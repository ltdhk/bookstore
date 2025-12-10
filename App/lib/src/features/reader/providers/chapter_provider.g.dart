// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier to manage current chapter index

@ProviderFor(CurrentChapterIndex)
const currentChapterIndexProvider = CurrentChapterIndexProvider._();

/// Notifier to manage current chapter index
final class CurrentChapterIndexProvider
    extends $NotifierProvider<CurrentChapterIndex, int> {
  /// Notifier to manage current chapter index
  const CurrentChapterIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentChapterIndexProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentChapterIndexHash();

  @$internal
  @override
  CurrentChapterIndex create() => CurrentChapterIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$currentChapterIndexHash() =>
    r'2fdebe86baf9b0595b2b2c843550437557a33d08';

/// Notifier to manage current chapter index

abstract class _$CurrentChapterIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider that fetches all reader data in a single optimized API call
/// This replaces the previous approach of making 2 separate API calls
/// (getBookDetails + getBookChapters) with just 1 call (getReaderData)
///
/// Note: Auth state changes are handled by ReaderScreen, which invalidates
/// this provider when user logs in/out to refresh chapter access permissions

@ProviderFor(readerData)
const readerDataProvider = ReaderDataFamily._();

/// Provider that fetches all reader data in a single optimized API call
/// This replaces the previous approach of making 2 separate API calls
/// (getBookDetails + getBookChapters) with just 1 call (getReaderData)
///
/// Note: Auth state changes are handled by ReaderScreen, which invalidates
/// this provider when user logs in/out to refresh chapter access permissions

final class ReaderDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReaderData>,
          ReaderData,
          FutureOr<ReaderData>
        >
    with $FutureModifier<ReaderData>, $FutureProvider<ReaderData> {
  /// Provider that fetches all reader data in a single optimized API call
  /// This replaces the previous approach of making 2 separate API calls
  /// (getBookDetails + getBookChapters) with just 1 call (getReaderData)
  ///
  /// Note: Auth state changes are handled by ReaderScreen, which invalidates
  /// this provider when user logs in/out to refresh chapter access permissions
  const ReaderDataProvider._({
    required ReaderDataFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'readerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$readerDataHash();

  @override
  String toString() {
    return r'readerDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReaderData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ReaderData> create(Ref ref) {
    final argument = this.argument as int;
    return readerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ReaderDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$readerDataHash() => r'551ba0899d3c07f51fb961a1cd30e342b6c444ac';

/// Provider that fetches all reader data in a single optimized API call
/// This replaces the previous approach of making 2 separate API calls
/// (getBookDetails + getBookChapters) with just 1 call (getReaderData)
///
/// Note: Auth state changes are handled by ReaderScreen, which invalidates
/// this provider when user logs in/out to refresh chapter access permissions

final class ReaderDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReaderData>, int> {
  const ReaderDataFamily._()
    : super(
        retry: null,
        name: r'readerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that fetches all reader data in a single optimized API call
  /// This replaces the previous approach of making 2 separate API calls
  /// (getBookDetails + getBookChapters) with just 1 call (getReaderData)
  ///
  /// Note: Auth state changes are handled by ReaderScreen, which invalidates
  /// this provider when user logs in/out to refresh chapter access permissions

  ReaderDataProvider call(int bookId) =>
      ReaderDataProvider._(argument: bookId, from: this);

  @override
  String toString() => r'readerDataProvider';
}

/// Provider that fetches chapter content by chapter index

@ProviderFor(chapterContent)
const chapterContentProvider = ChapterContentFamily._();

/// Provider that fetches chapter content by chapter index

final class ChapterContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChapterVO>,
          ChapterVO,
          FutureOr<ChapterVO>
        >
    with $FutureModifier<ChapterVO>, $FutureProvider<ChapterVO> {
  /// Provider that fetches chapter content by chapter index
  const ChapterContentProvider._({
    required ChapterContentFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'chapterContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chapterContentHash();

  @override
  String toString() {
    return r'chapterContentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ChapterVO> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ChapterVO> create(Ref ref) {
    final argument = this.argument as (int, int);
    return chapterContent(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterContentHash() => r'd494c9e3a7232777791381ee5f0e395830151a1a';

/// Provider that fetches chapter content by chapter index

final class ChapterContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ChapterVO>, (int, int)> {
  const ChapterContentFamily._()
    : super(
        retry: null,
        name: r'chapterContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that fetches chapter content by chapter index

  ChapterContentProvider call(int bookId, int chapterIndex) =>
      ChapterContentProvider._(argument: (bookId, chapterIndex), from: this);

  @override
  String toString() => r'chapterContentProvider';
}
