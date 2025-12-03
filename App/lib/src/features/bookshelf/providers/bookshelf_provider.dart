import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/bookshelf/data/bookshelf_local_storage.dart';

part 'bookshelf_provider.g.dart';

/// Provider for bookshelf items
@riverpod
class Bookshelf extends _$Bookshelf {
  @override
  Future<List<BookshelfItem>> build() async {
    final storage = await ref.watch(bookshelfLocalStorageProvider.future);
    return storage.getAllBooks();
  }

  /// Add a book to bookshelf
  Future<void> addBook({
    required String id,
    required String title,
    required String author,
    String? coverUrl,
    required String category,
  }) async {
    final storage = ref.read(bookshelfLocalStorageProvider).requireValue;
    final book = BookshelfItem(
      id: id,
      title: title,
      author: author,
      coverUrl: coverUrl,
      category: category,
      addedAt: DateTime.now(),
    );

    await storage.addBook(book);
    ref.invalidateSelf();
  }

  /// Remove a book from bookshelf
  Future<void> removeBook(String bookId) async {
    final storage = ref.read(bookshelfLocalStorageProvider).requireValue;
    await storage.removeBook(bookId);
    ref.invalidateSelf();
  }

  /// Remove multiple books from bookshelf
  Future<void> removeBooks(List<String> bookIds) async {
    final storage = ref.read(bookshelfLocalStorageProvider).requireValue;
    await storage.removeBooks(bookIds);
    ref.invalidateSelf();
  }

  /// Check if a book is in bookshelf
  bool isBookInShelf(String bookId) {
    final storage = ref.read(bookshelfLocalStorageProvider).requireValue;
    return storage.isBookInShelf(bookId);
  }

  /// Clear all books from bookshelf
  Future<void> clearAll() async {
    final storage = ref.read(bookshelfLocalStorageProvider).requireValue;
    await storage.clearAll();
    ref.invalidateSelf();
  }
}

/// Provider to check if a specific book is in bookshelf
/// This reads directly from local storage for immediate results
@riverpod
bool isBookInBookshelf(Ref ref, String bookId) {
  // Watch the bookshelf provider to trigger updates when data changes
  ref.watch(bookshelfProvider);

  // Read directly from storage for immediate, synchronous result
  final storageAsync = ref.read(bookshelfLocalStorageProvider);
  return storageAsync.whenOrNull(data: (storage) => storage.isBookInShelf(bookId)) ?? false;
}

/// Provider for bookshelf count
@riverpod
int bookshelfCount(Ref ref) {
  final bookshelfAsync = ref.watch(bookshelfProvider);
  return bookshelfAsync.maybeWhen(
    data: (books) => books.length,
    orElse: () => 0,
  );
}
