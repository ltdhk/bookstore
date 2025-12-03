import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/services/networking/dio_provider.dart';
import 'package:novelpop/src/features/home/data/models/book_vo.dart';
import 'package:novelpop/src/features/reader/data/models/chapter_vo.dart';
import 'package:novelpop/src/features/reader/data/models/reader_data.dart';

part 'book_api_service.g.dart';

@riverpod
BookApiService bookApiService(Ref ref) {
  return BookApiService(ref.watch(dioProvider));
}

class BookApiService {
  final Dio _dio;

  BookApiService(this._dio);

  /// Get home books (hot, new, male, female) with pagination
  Future<Map<String, List<BookVO>>> getHomeBooks({
    int page = 1,
    int pageSize = 20,
    String? language,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'pageSize': pageSize,
    };

    if (language != null) {
      queryParams['language'] = language;
    }

    final response = await _dio.get(
      '/api/v1/books/home',
      queryParameters: queryParams,
    );
    final data = response.data['data'] as Map<String, dynamic>;

    final Map<String, List<BookVO>> result = {};
    data.forEach((key, value) {
      result[key] = (value as List)
          .map((json) => BookVO.fromJson(json as Map<String, dynamic>))
          .toList();
    });

    return result;
  }

  /// Search books by keyword
  Future<List<BookVO>> searchBooks(String keyword) async {
    final response = await _dio.get(
      '/api/v1/books/search',
      queryParameters: {'keyword': keyword},
    );
    final data = response.data['data'] as List;
    return data.map((json) => BookVO.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get book details
  Future<BookVO> getBookDetails(int id) async {
    final response = await _dio.get('/api/v1/books/$id');
    return BookVO.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Like a book
  Future<void> likeBook(int id) async {
    await _dio.post('/api/v1/books/$id/like');
  }

  /// Get chapters for a book
  /// [includeFirstChapter] - if true, the first chapter's content will be included
  Future<List<ChapterVO>> getBookChapters(int bookId, {bool includeFirstChapter = false}) async {
    final response = await _dio.get(
      '/api/v1/books/$bookId/chapters',
      queryParameters: includeFirstChapter ? {'includeFirstChapter': true} : null,
    );
    final data = response.data['data'] as List;
    return data.map((json) => ChapterVO.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get chapter details by chapter ID
  Future<ChapterVO> getChapterDetails(int chapterId) async {
    final response = await _dio.get('/api/v1/books/chapters/$chapterId');
    return ChapterVO.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Get all reader data in a single call - optimized for reader page
  /// Combines: book details + chapter list + first chapter content + subscription status
  /// This reduces API calls from 2-3 to just 1
  Future<ReaderData> getReaderData(int bookId) async {
    final response = await _dio.get('/api/v1/books/$bookId/reader-data');
    return ReaderData.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
