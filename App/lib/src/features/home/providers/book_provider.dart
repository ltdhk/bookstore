import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/features/home/data/book_api_service.dart';
import 'package:book_store/src/features/home/data/models/book_vo.dart';

part 'book_provider.g.dart';

/// Provider for home books (all categories)
@riverpod
Future<Map<String, List<BookVO>>> homeBooks(Ref ref) async {
  final bookService = ref.watch(bookApiServiceProvider);
  return await bookService.getHomeBooks();
}

/// Provider for books by category
@riverpod
Future<List<BookVO>> booksByCategory(Ref ref, String category) async {
  final allBooks = await ref.watch(homeBooksProvider.future);
  return allBooks[category] ?? [];
}

/// State class for search results
class SearchResultsState {
  final List<BookVO> books;
  final bool isLoading;
  final String? error;

  SearchResultsState({
    required this.books,
    this.isLoading = false,
    this.error,
  });

  SearchResultsState copyWith({
    List<BookVO>? books,
    bool? isLoading,
    String? error,
  }) {
    return SearchResultsState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for search results with state management
@Riverpod(keepAlive: true)
class SearchResults extends _$SearchResults {
  @override
  SearchResultsState build(String keyword) {
    if (keyword.isNotEmpty) {
      Future.microtask(() => search(keyword));
    }
    return SearchResultsState(books: []);
  }

  /// Search for books
  Future<void> search(String keyword) async {
    if (keyword.isEmpty) {
      state = SearchResultsState(books: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookService = ref.read(bookApiServiceProvider);
      final results = await bookService.searchBooks(keyword);

      if (!ref.mounted) return;

      state = SearchResultsState(
        books: results,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = SearchResultsState(
        books: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update book likes count locally
  void updateBookLikes(int bookId) {
    final updatedBooks = state.books.map((book) {
      if (book.id == bookId) {
        return book.copyWith(likes: (book.likes ?? 0) + 1);
      }
      return book;
    }).toList();

    state = state.copyWith(books: updatedBooks);
  }
}

/// Provider for book details
@riverpod
Future<BookVO> bookDetails(Ref ref, int id) async {
  final bookService = ref.watch(bookApiServiceProvider);
  return await bookService.getBookDetails(id);
}
