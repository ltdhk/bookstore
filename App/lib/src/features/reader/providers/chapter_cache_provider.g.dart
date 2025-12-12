// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages chapter caching for seamless reading experience

@ProviderFor(ChapterCache)
const chapterCacheProvider = ChapterCacheFamily._();

/// Manages chapter caching for seamless reading experience
final class ChapterCacheProvider
    extends $NotifierProvider<ChapterCache, ChapterCacheState> {
  /// Manages chapter caching for seamless reading experience
  const ChapterCacheProvider._({
    required ChapterCacheFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'chapterCacheProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chapterCacheHash();

  @override
  String toString() {
    return r'chapterCacheProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChapterCache create() => ChapterCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChapterCacheState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChapterCacheState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterCacheProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterCacheHash() => r'a419b3619f69854cfdedac4aa1dc491e0b9e1103';

/// Manages chapter caching for seamless reading experience

final class ChapterCacheFamily extends $Family
    with
        $ClassFamilyOverride<
          ChapterCache,
          ChapterCacheState,
          ChapterCacheState,
          ChapterCacheState,
          int
        > {
  const ChapterCacheFamily._()
    : super(
        retry: null,
        name: r'chapterCacheProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages chapter caching for seamless reading experience

  ChapterCacheProvider call(int bookId) =>
      ChapterCacheProvider._(argument: bookId, from: this);

  @override
  String toString() => r'chapterCacheProvider';
}

/// Manages chapter caching for seamless reading experience

abstract class _$ChapterCache extends $Notifier<ChapterCacheState> {
  late final _$args = ref.$arg as int;
  int get bookId => _$args;

  ChapterCacheState build(int bookId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ChapterCacheState, ChapterCacheState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChapterCacheState, ChapterCacheState>,
              ChapterCacheState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider to track chapter boundaries (scroll positions)

@ProviderFor(ChapterBoundaries)
const chapterBoundariesProvider = ChapterBoundariesFamily._();

/// Provider to track chapter boundaries (scroll positions)
final class ChapterBoundariesProvider
    extends $NotifierProvider<ChapterBoundaries, Map<int, ChapterBoundary>> {
  /// Provider to track chapter boundaries (scroll positions)
  const ChapterBoundariesProvider._({
    required ChapterBoundariesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'chapterBoundariesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chapterBoundariesHash();

  @override
  String toString() {
    return r'chapterBoundariesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChapterBoundaries create() => ChapterBoundaries();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, ChapterBoundary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, ChapterBoundary>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChapterBoundariesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chapterBoundariesHash() => r'fbb90cee13ef01b2553f25db2706ca6f2ebc50b9';

/// Provider to track chapter boundaries (scroll positions)

final class ChapterBoundariesFamily extends $Family
    with
        $ClassFamilyOverride<
          ChapterBoundaries,
          Map<int, ChapterBoundary>,
          Map<int, ChapterBoundary>,
          Map<int, ChapterBoundary>,
          int
        > {
  const ChapterBoundariesFamily._()
    : super(
        retry: null,
        name: r'chapterBoundariesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to track chapter boundaries (scroll positions)

  ChapterBoundariesProvider call(int bookId) =>
      ChapterBoundariesProvider._(argument: bookId, from: this);

  @override
  String toString() => r'chapterBoundariesProvider';
}

/// Provider to track chapter boundaries (scroll positions)

abstract class _$ChapterBoundaries
    extends $Notifier<Map<int, ChapterBoundary>> {
  late final _$args = ref.$arg as int;
  int get bookId => _$args;

  Map<int, ChapterBoundary> build(int bookId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<Map<int, ChapterBoundary>, Map<int, ChapterBoundary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, ChapterBoundary>, Map<int, ChapterBoundary>>,
              Map<int, ChapterBoundary>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
