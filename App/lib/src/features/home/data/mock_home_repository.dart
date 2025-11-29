import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'mock_home_repository.g.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.category,
  });

  /// Get cover URL with fallback to default cover
  String get effectiveCoverUrl => coverUrl ?? 'https://via.placeholder.com/300x400.png?text=No+Cover';
}

@riverpod
MockHomeRepository mockHomeRepository(Ref ref) {
  return MockHomeRepository();
}

class MockHomeRepository {
  Future<List<String>> getBanners() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      'https://picsum.photos/id/1/800/400',
      'https://picsum.photos/id/2/800/400',
      'https://picsum.photos/id/3/800/400',
    ];
  }

  Future<List<Book>> getBooks(String category) async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      6,
      (index) => Book(
        id: '$category-$index',
        title: '$category Book $index: The Story of ${index + 1}',
        author: 'Author $index',
        coverUrl: 'https://picsum.photos/id/${10 + index}/300/450',
        category: category,
      ),
    );
  }
}

@riverpod
Future<List<String>> homeBanners(Ref ref) {
  return ref.watch(mockHomeRepositoryProvider).getBanners();
}

@riverpod
Future<List<Book>> homeBooks(Ref ref, String category) {
  return ref.watch(mockHomeRepositoryProvider).getBooks(category);
}
