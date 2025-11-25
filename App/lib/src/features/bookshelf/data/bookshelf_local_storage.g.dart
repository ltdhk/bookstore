// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookshelf_local_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookshelfLocalStorage)
const bookshelfLocalStorageProvider = BookshelfLocalStorageProvider._();

final class BookshelfLocalStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookshelfLocalStorage>,
          BookshelfLocalStorage,
          FutureOr<BookshelfLocalStorage>
        >
    with
        $FutureModifier<BookshelfLocalStorage>,
        $FutureProvider<BookshelfLocalStorage> {
  const BookshelfLocalStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookshelfLocalStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookshelfLocalStorageHash();

  @$internal
  @override
  $FutureProviderElement<BookshelfLocalStorage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookshelfLocalStorage> create(Ref ref) {
    return bookshelfLocalStorage(ref);
  }
}

String _$bookshelfLocalStorageHash() =>
    r'553382730864e962f67e096e32d74355dc9ae081';
