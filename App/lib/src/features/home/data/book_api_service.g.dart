// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookApiService)
const bookApiServiceProvider = BookApiServiceProvider._();

final class BookApiServiceProvider
    extends $FunctionalProvider<BookApiService, BookApiService, BookApiService>
    with $Provider<BookApiService> {
  const BookApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookApiServiceHash();

  @$internal
  @override
  $ProviderElement<BookApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BookApiService create(Ref ref) {
    return bookApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookApiService>(value),
    );
  }
}

String _$bookApiServiceHash() => r'aa3d672271aec94d9063780532ea68c974336118';
