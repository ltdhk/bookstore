import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reading_history_local_storage.g.dart';

/// Reading history item model
class ReadingHistoryItem {
  final String bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final DateTime lastReadAt;

  ReadingHistoryItem({
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    required this.lastReadAt,
  });

  /// Get cover URL with fallback to default cover
  String get effectiveCoverUrl => coverUrl ?? 'https://via.placeholder.com/300x400.png?text=No+Cover';

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'lastReadAt': lastReadAt.toIso8601String(),
    };
  }

  factory ReadingHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryItem(
      bookId: json['bookId'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverUrl: json['coverUrl'] as String?,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
    );
  }
}

/// Local storage service for reading history
class ReadingHistoryLocalStorage {
  static const String _boxName = 'reading_history';
  static const int _maxHistoryItems = 100; // Limit history to 100 items
  Box<dynamic>? _box;

  /// Initialize the storage
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Get the box (throws if not initialized)
  Box<dynamic> get _safeBox {
    if (_box == null) {
      throw StateError('ReadingHistoryLocalStorage not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all reading history items
  List<ReadingHistoryItem> getAllHistory() {
    try {
      final historyData = _safeBox.get('history', defaultValue: <dynamic>[]) as List<dynamic>;
      return historyData
          .map((item) => ReadingHistoryItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList()
        ..sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt)); // Sort by last read time, newest first
    } catch (e) {
      print('Error getting reading history: $e');
      return [];
    }
  }

  /// Add or update a reading history item
  Future<void> addOrUpdateHistory({
    required String bookId,
    required String title,
    required String author,
    String? coverUrl,
  }) async {
    try {
      final history = getAllHistory();

      // Remove existing entry if present
      history.removeWhere((item) => item.bookId == bookId);

      // Add new entry at the beginning
      final newItem = ReadingHistoryItem(
        bookId: bookId,
        title: title,
        author: author,
        coverUrl: coverUrl,
        lastReadAt: DateTime.now(),
      );
      history.insert(0, newItem);

      // Limit to max items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      // Save to storage
      await _safeBox.put('history', history.map((item) => item.toJson()).toList());
    } catch (e) {
      print('Error adding reading history: $e');
      rethrow;
    }
  }

  /// Remove a history item
  Future<void> removeHistory(String bookId) async {
    try {
      final history = getAllHistory();
      history.removeWhere((item) => item.bookId == bookId);
      await _safeBox.put('history', history.map((item) => item.toJson()).toList());
    } catch (e) {
      print('Error removing history: $e');
      rethrow;
    }
  }

  /// Clear all history
  Future<void> clearAll() async {
    try {
      await _safeBox.clear();
    } catch (e) {
      print('Error clearing reading history: $e');
      rethrow;
    }
  }

  /// Get history count
  int getHistoryCount() {
    return getAllHistory().length;
  }
}

@Riverpod(keepAlive: true)
Future<ReadingHistoryLocalStorage> readingHistoryLocalStorage(Ref ref) async {
  final storage = ReadingHistoryLocalStorage();
  await storage.init();
  return storage;
}
