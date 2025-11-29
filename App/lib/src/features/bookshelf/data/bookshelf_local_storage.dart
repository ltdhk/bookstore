import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bookshelf_local_storage.g.dart';

/// Book model for local storage
class BookshelfItem {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String category;
  final DateTime addedAt;

  BookshelfItem({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.category,
    required this.addedAt,
  });

  /// Get cover URL with fallback to default cover
  String get effectiveCoverUrl => coverUrl ?? 'https://via.placeholder.com/300x400.png?text=No+Cover';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'category': category,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory BookshelfItem.fromJson(Map<String, dynamic> json) {
    return BookshelfItem(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String?,
      category: json['category'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

/// Local storage service for bookshelf
class BookshelfLocalStorage {
  static const String _boxName = 'bookshelf';
  Box<dynamic>? _box;

  /// Initialize the storage
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Get the box (throws if not initialized)
  Box<dynamic> get _safeBox {
    if (_box == null) {
      throw StateError('BookshelfLocalStorage not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all books in bookshelf
  List<BookshelfItem> getAllBooks() {
    try {
      final booksData = _safeBox.get('books', defaultValue: <dynamic>[]) as List<dynamic>;
      return booksData
          .map((item) => BookshelfItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt)); // Sort by added date, newest first
    } catch (e) {
      print('Error getting all books: $e');
      return [];
    }
  }

  /// Check if a book is in bookshelf
  bool isBookInShelf(String bookId) {
    try {
      final books = getAllBooks();
      return books.any((book) => book.id == bookId);
    } catch (e) {
      print('Error checking book in shelf: $e');
      return false;
    }
  }

  /// Add a book to bookshelf
  Future<void> addBook(BookshelfItem book) async {
    try {
      final books = getAllBooks();

      // Check if book already exists
      if (books.any((b) => b.id == book.id)) {
        print('Book already in bookshelf: ${book.id}');
        return;
      }

      books.add(book);
      await _safeBox.put('books', books.map((b) => b.toJson()).toList());
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  /// Remove a book from bookshelf
  Future<void> removeBook(String bookId) async {
    try {
      final books = getAllBooks();
      books.removeWhere((book) => book.id == bookId);
      await _safeBox.put('books', books.map((b) => b.toJson()).toList());
    } catch (e) {
      print('Error removing book: $e');
      rethrow;
    }
  }

  /// Remove multiple books from bookshelf
  Future<void> removeBooks(List<String> bookIds) async {
    try {
      final books = getAllBooks();
      books.removeWhere((book) => bookIds.contains(book.id));
      await _safeBox.put('books', books.map((b) => b.toJson()).toList());
    } catch (e) {
      print('Error removing books: $e');
      rethrow;
    }
  }

  /// Clear all books from bookshelf
  Future<void> clearAll() async {
    try {
      await _safeBox.clear();
    } catch (e) {
      print('Error clearing bookshelf: $e');
      rethrow;
    }
  }

  /// Get book count
  int getBookCount() {
    return getAllBooks().length;
  }
}

@Riverpod(keepAlive: true)
Future<BookshelfLocalStorage> bookshelfLocalStorage(Ref ref) async {
  final storage = BookshelfLocalStorage();
  await storage.init();
  return storage;
}
