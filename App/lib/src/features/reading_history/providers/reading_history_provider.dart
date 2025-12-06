import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/reading_history/data/reading_history_local_storage.dart';

part 'reading_history_provider.g.dart';

/// Provider for reading history items
@riverpod
class ReadingHistory extends _$ReadingHistory {
  @override
  Future<List<ReadingHistoryItem>> build() async {
    final storage = await ref.watch(readingHistoryLocalStorageProvider.future);
    return storage.getAllHistory();
  }

  /// Add or update a reading history item
  Future<void> addOrUpdateHistory({
    required String bookId,
    required String title,
    required String author,
    String? coverUrl,
  }) async {
    final storage = ref.read(readingHistoryLocalStorageProvider).requireValue;
    await storage.addOrUpdateHistory(
      bookId: bookId,
      title: title,
      author: author,
      coverUrl: coverUrl,
    );
    // Check if still mounted after async operation
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }

  /// Remove a history item
  Future<void> removeHistory(String bookId) async {
    final storage = ref.read(readingHistoryLocalStorageProvider).requireValue;
    await storage.removeHistory(bookId);
    // Check if still mounted after async operation
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }

  /// Clear all history
  Future<void> clearAll() async {
    final storage = ref.read(readingHistoryLocalStorageProvider).requireValue;
    await storage.clearAll();
    // Check if still mounted after async operation
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }
}

/// Provider for reading history count
@riverpod
int readingHistoryCount(Ref ref) {
  final historyAsync = ref.watch(readingHistoryProvider);
  return historyAsync.maybeWhen(
    data: (history) => history.length,
    orElse: () => 0,
  );
}
