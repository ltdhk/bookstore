// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_pagination_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for paginated books by category

@ProviderFor(BooksPagination)
const booksPaginationProvider = BooksPaginationFamily._();

/// Notifier for paginated books by category
final class BooksPaginationProvider
    extends $NotifierProvider<BooksPagination, BooksPaginationState> {
  /// Notifier for paginated books by category
  const BooksPaginationProvider._({
    required BooksPaginationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'booksPaginationProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$booksPaginationHash();

  @override
  String toString() {
    return r'booksPaginationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BooksPagination create() => BooksPagination();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BooksPaginationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BooksPaginationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BooksPaginationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$booksPaginationHash() => r'e58f13b5784d1008361a45d5f1336a7054f384ce';

/// Notifier for paginated books by category

final class BooksPaginationFamily extends $Family
    with
        $ClassFamilyOverride<
          BooksPagination,
          BooksPaginationState,
          BooksPaginationState,
          BooksPaginationState,
          String
        > {
  const BooksPaginationFamily._()
    : super(
        retry: null,
        name: r'booksPaginationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Notifier for paginated books by category

  BooksPaginationProvider call(String category) =>
      BooksPaginationProvider._(argument: category, from: this);

  @override
  String toString() => r'booksPaginationProvider';
}

/// Notifier for paginated books by category

abstract class _$BooksPagination extends $Notifier<BooksPaginationState> {
  late final _$args = ref.$arg as String;
  String get category => _$args;

  BooksPaginationState build(String category);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<BooksPaginationState, BooksPaginationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BooksPaginationState, BooksPaginationState>,
              BooksPaginationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
