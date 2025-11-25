import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgress {
  final int chapterIndex;
  final int chapterId;
  final double scrollOffset;
  final DateTime lastReadTime;

  ReadingProgress({
    required this.chapterIndex,
    required this.chapterId,
    required this.scrollOffset,
    required this.lastReadTime,
  });

  Map<String, dynamic> toJson() => {
        'chapterIndex': chapterIndex,
        'chapterId': chapterId,
        'scrollOffset': scrollOffset,
        'lastReadTime': lastReadTime.toIso8601String(),
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      chapterIndex: json['chapterIndex'] as int,
      chapterId: json['chapterId'] as int,
      scrollOffset: (json['scrollOffset'] as num).toDouble(),
      lastReadTime: DateTime.parse(json['lastReadTime'] as String),
    );
  }
}

class ReadingProgressService {
  static const String _keyPrefix = 'reading_progress_';

  /// Save reading progress for a book
  Future<void> saveReadingProgress({
    required int bookId,
    required int chapterIndex,
    required int chapterId,
    required double scrollOffset,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final progress = ReadingProgress(
      chapterIndex: chapterIndex,
      chapterId: chapterId,
      scrollOffset: scrollOffset,
      lastReadTime: DateTime.now(),
    );

    final key = '$_keyPrefix$bookId';
    await prefs.setString(key, jsonEncode(progress.toJson()));
  }

  /// Get reading progress for a book
  Future<ReadingProgress?> getReadingProgress(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$bookId';
    final progressJson = prefs.getString(key);

    if (progressJson == null) {
      return null;
    }

    try {
      final Map<String, dynamic> json = jsonDecode(progressJson);
      return ReadingProgress.fromJson(json);
    } catch (e) {
      // Invalid JSON, return null
      return null;
    }
  }

  /// Clear reading progress for a book
  Future<void> clearReadingProgress(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$bookId';
    await prefs.remove(key);
  }
}
