import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/home/data/book_api_service.dart';
import 'package:novelpop/src/features/home/data/models/book_vo.dart';
import 'package:novelpop/src/features/settings/data/locale_provider.dart';

part 'books_pagination_provider.g.dart';

/// State class for paginated books
class BooksPaginationState {
  final List<BookVO> books;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  BooksPaginationState({
    required this.books,
    required this.currentPage,
    required this.hasMore,
    this.isLoading = false,
    this.error,
  });

  BooksPaginationState copyWith({
    List<BookVO>? books,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return BooksPaginationState(
      books: books ?? this.books,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for paginated books by category
@Riverpod(keepAlive: true)
class BooksPagination extends _$BooksPagination {
  static const int _pageSize = 20;
  String _category = '';

  @override
  BooksPaginationState build(String category) {
    _category = category;
    // Load first page on initialization
    Future.microtask(() => loadNextPage());
    return BooksPaginationState(
      books: [],
      currentPage: 0,
      hasMore: true,
      isLoading: false,
    );
  }

  /// Get user's selected language from settings
  /// Falls back to English if not available
  Future<String> _getUserLanguage() async {
    try {
      // Get user's selected language from settings
      final locale = await ref.read(localeControllerProvider.future);
      return locale.languageCode;
    } catch (e) {
      // Fallback to English if error
      return 'en';
    }
  }

  /// Load next page
  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookService = ref.read(bookApiServiceProvider);
      final nextPage = state.currentPage + 1;
      final language = await _getUserLanguage();

      final result = await bookService.getHomeBooks(
        page: nextPage,
        pageSize: _pageSize,
        language: language,
      );

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      final newBooks = result[_category] ?? [];

      // If we got fewer books than page size, we've reached the end
      final hasMore = newBooks.length >= _pageSize;

      state = state.copyWith(
        books: [...state.books, ...newBooks],
        currentPage: nextPage,
        hasMore: hasMore,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update book likes count
  void updateBookLikes(int bookId) {
    final updatedBooks = state.books.map((book) {
      if (book.id == bookId) {
        return book.copyWith(likes: (book.likes ?? 0) + 1);
      }
      return book;
    }).toList();

    state = state.copyWith(books: updatedBooks);
  }

  /// Refresh (reload from first page)
  /// [forceLanguage] - if provided, use this language instead of fetching from settings
  Future<void> refresh({String? forceLanguage}) async {
    // Keep current books during refresh to avoid showing loading indicator
    final currentBooks = state.books;

    // Reset pagination state but keep books
    state = BooksPaginationState(
      books: currentBooks,
      currentPage: 0,
      hasMore: true,
      isLoading: false, // Set to false so loadNextPage can proceed
    );

    // Load first page
    final bookService = ref.read(bookApiServiceProvider);
    final language = forceLanguage ?? await _getUserLanguage();

    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await bookService.getHomeBooks(
        page: 1,
        pageSize: _pageSize,
        language: language,
      );

      if (!ref.mounted) return;

      final newBooks = result[_category] ?? [];
      final hasMore = newBooks.length >= _pageSize;

      // Replace old books with new books
      state = state.copyWith(
        books: newBooks,
        currentPage: 1,
        hasMore: hasMore,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
