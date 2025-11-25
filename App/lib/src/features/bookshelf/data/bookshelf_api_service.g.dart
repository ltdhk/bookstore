// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookshelf_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookshelfApiService)
const bookshelfApiServiceProvider = BookshelfApiServiceProvider._();

final class BookshelfApiServiceProvider
    extends
        $FunctionalProvider<
          BookshelfApiService,
          BookshelfApiService,
          BookshelfApiService
        >
    with $Provider<BookshelfApiService> {
  const BookshelfApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookshelfApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookshelfApiServiceHash();

  @$internal
  @override
  $ProviderElement<BookshelfApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookshelfApiService create(Ref ref) {
    return bookshelfApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookshelfApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookshelfApiService>(value),
    );
  }
}

String _$bookshelfApiServiceHash() =>
    r'0c4d9ef895323a00ef6f702e989ba709c0413d1c';
