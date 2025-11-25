// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for home books (all categories)

@ProviderFor(homeBooks)
const homeBooksProvider = HomeBooksProvider._();

/// Provider for home books (all categories)

final class HomeBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<BookVO>>>,
          Map<String, List<BookVO>>,
          FutureOr<Map<String, List<BookVO>>>
        >
    with
        $FutureModifier<Map<String, List<BookVO>>>,
        $FutureProvider<Map<String, List<BookVO>>> {
  /// Provider for home books (all categories)
  const HomeBooksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBooksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBooksHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, List<BookVO>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, List<BookVO>>> create(Ref ref) {
    return homeBooks(ref);
  }
}

String _$homeBooksHash() => r'8952dbfebe539a745d3bb90ed8c7db4f63e59cbd';

/// Provider for books by category

@ProviderFor(booksByCategory)
const booksByCategoryProvider = BooksByCategoryFamily._();

/// Provider for books by category

final class BooksByCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookVO>>,
          List<BookVO>,
          FutureOr<List<BookVO>>
        >
    with $FutureModifier<List<BookVO>>, $FutureProvider<List<BookVO>> {
  /// Provider for books by category
  const BooksByCategoryProvider._({
    required BooksByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'booksByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$booksByCategoryHash();

  @override
  String toString() {
    return r'booksByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BookVO>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookVO>> create(Ref ref) {
    final argument = this.argument as String;
    return booksByCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BooksByCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$booksByCategoryHash() => r'dfc0e5dafd501057401f12cbc844dde22206288e';

/// Provider for books by category

final class BooksByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BookVO>>, String> {
  const BooksByCategoryFamily._()
    : super(
        retry: null,
        name: r'booksByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for books by category

  BooksByCategoryProvider call(String category) =>
      BooksByCategoryProvider._(argument: category, from: this);

  @override
  String toString() => r'booksByCategoryProvider';
}

/// Notifier for search results with state management

@ProviderFor(SearchResults)
const searchResultsProvider = SearchResultsFamily._();

/// Notifier for search results with state management
final class SearchResultsProvider
    extends $NotifierProvider<SearchResults, SearchResultsState> {
  /// Notifier for search results with state management
  const SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchResults create() => SearchResults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchResultsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchResultsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'1d50135d53618c2f2eb01113d262eb4abd3a9fa8';

/// Notifier for search results with state management

final class SearchResultsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchResults,
          SearchResultsState,
          SearchResultsState,
          SearchResultsState,
          String
        > {
  const SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Notifier for search results with state management

  SearchResultsProvider call(String keyword) =>
      SearchResultsProvider._(argument: keyword, from: this);

  @override
  String toString() => r'searchResultsProvider';
}

/// Notifier for search results with state management

abstract class _$SearchResults extends $Notifier<SearchResultsState> {
  late final _$args = ref.$arg as String;
  String get keyword => _$args;

  SearchResultsState build(String keyword);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<SearchResultsState, SearchResultsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchResultsState, SearchResultsState>,
              SearchResultsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for book details

@ProviderFor(bookDetails)
const bookDetailsProvider = BookDetailsFamily._();

/// Provider for book details

final class BookDetailsProvider
    extends $FunctionalProvider<AsyncValue<BookVO>, BookVO, FutureOr<BookVO>>
    with $FutureModifier<BookVO>, $FutureProvider<BookVO> {
  /// Provider for book details
  const BookDetailsProvider._({
    required BookDetailsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'bookDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookDetailsHash();

  @override
  String toString() {
    return r'bookDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookVO> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BookVO> create(Ref ref) {
    final argument = this.argument as int;
    return bookDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookDetailsHash() => r'57970c128d907f5103dd3c5e1a388198d02c9f85';

/// Provider for book details

final class BookDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookVO>, int> {
  const BookDetailsFamily._()
    : super(
        retry: null,
        name: r'bookDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for book details

  BookDetailsProvider call(int id) =>
      BookDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'bookDetailsProvider';
}
