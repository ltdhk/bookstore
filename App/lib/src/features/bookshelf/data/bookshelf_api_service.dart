import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/services/networking/dio_provider.dart';

part 'bookshelf_api_service.g.dart';

@riverpod
BookshelfApiService bookshelfApiService(Ref ref) {
  return BookshelfApiService(ref.watch(dioProvider));
}

class BookshelfApiService {
  final Dio _dio;

  BookshelfApiService(this._dio);

  /// Check if a book is in the bookshelf
  Future<bool> checkBookInShelf(int bookId) async {
    final response = await _dio.get(
      '/api/v1/users/bookshelf/check',
      queryParameters: {'bookId': bookId},
    );
    return response.data['data'] as bool;
  }

  /// Add a book to bookshelf
  Future<void> addToBookshelf(int bookId) async {
    await _dio.post(
      '/api/v1/users/bookshelf',
      data: {'bookId': bookId},
    );
  }

  /// Remove a book from bookshelf
  Future<void> removeFromBookshelf(int bookId) async {
    await _dio.delete(
      '/api/v1/users/bookshelf',
      data: {'bookId': bookId},
    );
  }
}
