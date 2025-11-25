// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookshelf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for bookshelf items

@ProviderFor(Bookshelf)
const bookshelfProvider = BookshelfProvider._();

/// Provider for bookshelf items
final class BookshelfProvider
    extends $AsyncNotifierProvider<Bookshelf, List<BookshelfItem>> {
  /// Provider for bookshelf items
  const BookshelfProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookshelfProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookshelfHash();

  @$internal
  @override
  Bookshelf create() => Bookshelf();
}

String _$bookshelfHash() => r'f0b628361c7e74aec5714f3e5a481a21fb7675a4';

/// Provider for bookshelf items

abstract class _$Bookshelf extends $AsyncNotifier<List<BookshelfItem>> {
  FutureOr<List<BookshelfItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<BookshelfItem>>, List<BookshelfItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BookshelfItem>>, List<BookshelfItem>>,
              AsyncValue<List<BookshelfItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider to check if a specific book is in bookshelf
/// This reads directly from local storage for immediate results

@ProviderFor(isBookInBookshelf)
const isBookInBookshelfProvider = IsBookInBookshelfFamily._();

/// Provider to check if a specific book is in bookshelf
/// This reads directly from local storage for immediate results

final class IsBookInBookshelfProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider to check if a specific book is in bookshelf
  /// This reads directly from local storage for immediate results
  const IsBookInBookshelfProvider._({
    required IsBookInBookshelfFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isBookInBookshelfProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isBookInBookshelfHash();

  @override
  String toString() {
    return r'isBookInBookshelfProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isBookInBookshelf(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsBookInBookshelfProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isBookInBookshelfHash() => r'9694ea182ebdb2dfa24272be7f9976a039755797';

/// Provider to check if a specific book is in bookshelf
/// This reads directly from local storage for immediate results

final class IsBookInBookshelfFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsBookInBookshelfFamily._()
    : super(
        retry: null,
        name: r'isBookInBookshelfProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider to check if a specific book is in bookshelf
  /// This reads directly from local storage for immediate results

  IsBookInBookshelfProvider call(String bookId) =>
      IsBookInBookshelfProvider._(argument: bookId, from: this);

  @override
  String toString() => r'isBookInBookshelfProvider';
}

/// Provider for bookshelf count

@ProviderFor(bookshelfCount)
const bookshelfCountProvider = BookshelfCountProvider._();

/// Provider for bookshelf count

final class BookshelfCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Provider for bookshelf count
  const BookshelfCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookshelfCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookshelfCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return bookshelfCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$bookshelfCountHash() => r'40c6e0028e7e8174a17e9f0d57097d7be32a8aec';
