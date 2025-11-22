// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_home_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mockHomeRepository)
const mockHomeRepositoryProvider = MockHomeRepositoryProvider._();

final class MockHomeRepositoryProvider
    extends
        $FunctionalProvider<
          MockHomeRepository,
          MockHomeRepository,
          MockHomeRepository
        >
    with $Provider<MockHomeRepository> {
  const MockHomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockHomeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockHomeRepositoryHash();

  @$internal
  @override
  $ProviderElement<MockHomeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MockHomeRepository create(Ref ref) {
    return mockHomeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MockHomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MockHomeRepository>(value),
    );
  }
}

String _$mockHomeRepositoryHash() =>
    r'3d1d2d4159e379a995ca4ce4d1f60235e1130ab2';

@ProviderFor(homeBanners)
const homeBannersProvider = HomeBannersProvider._();

final class HomeBannersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  const HomeBannersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBannersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannersHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return homeBanners(ref);
  }
}

String _$homeBannersHash() => r'adfd3b5e9f9b5fd90fcd372e72cd844fa33f89d3';

@ProviderFor(homeBooks)
const homeBooksProvider = HomeBooksFamily._();

final class HomeBooksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Book>>,
          List<Book>,
          FutureOr<List<Book>>
        >
    with $FutureModifier<List<Book>>, $FutureProvider<List<Book>> {
  const HomeBooksProvider._({
    required HomeBooksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'homeBooksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeBooksHash();

  @override
  String toString() {
    return r'homeBooksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Book>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Book>> create(Ref ref) {
    final argument = this.argument as String;
    return homeBooks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeBooksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeBooksHash() => r'fae57e7a59589f38756c012395984fc5ca12c83d';

final class HomeBooksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Book>>, String> {
  const HomeBooksFamily._()
    : super(
        retry: null,
        name: r'homeBooksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeBooksProvider call(String category) =>
      HomeBooksProvider._(argument: category, from: this);

  @override
  String toString() => r'homeBooksProvider';
}
