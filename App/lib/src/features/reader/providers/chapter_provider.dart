import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/features/home/data/book_api_service.dart';
import 'package:book_store/src/features/reader/data/models/chapter_vo.dart';
import 'package:book_store/src/features/reader/data/models/reader_data.dart';

// Re-export ReaderData for compatibility
export 'package:book_store/src/features/reader/data/models/reader_data.dart';

part 'chapter_provider.g.dart';

/// Notifier to manage current chapter index
@riverpod
class CurrentChapterIndex extends _$CurrentChapterIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Provider that fetches all reader data in a single optimized API call
/// This replaces the previous approach of making 2 separate API calls
/// (getBookDetails + getBookChapters) with just 1 call (getReaderData)
@riverpod
Future<ReaderData> readerData(Ref ref, int bookId) async {
  final bookService = ref.watch(bookApiServiceProvider);

  // Single optimized API call that returns:
  // - Book details with chapter count
  // - All chapters with first chapter content
  // - Subscription status check
  // This reduces DB queries from 5+ to just 3
  return await bookService.getReaderData(bookId);
}

/// Provider that fetches chapter content by chapter index
@riverpod
Future<ChapterVO> chapterContent(Ref ref, int bookId, int chapterIndex) async {
  final bookService = ref.watch(bookApiServiceProvider);

  // Read (not watch) to avoid triggering unnecessary rebuilds
  // The readerData is already loaded and cached by the parent widget
  final readerData = await ref.read(readerDataProvider(bookId).future);

  if (readerData.chapters.isEmpty) {
    throw Exception('No chapters available for this book');
  }

  if (chapterIndex < 0 || chapterIndex >= readerData.chapters.length) {
    throw Exception('Invalid chapter index: $chapterIndex (total chapters: ${readerData.chapters.length})');
  }

  final cachedChapter = readerData.chapters[chapterIndex];

  // Check if user can access this chapter
  final canAccess = cachedChapter.canAccess ?? cachedChapter.isFree;
  if (!canAccess) {
    // User cannot access this chapter, return the cached chapter without content
    // The UI will show the membership upgrade section
    return cachedChapter;
  }

  // Check if the chapter content is already loaded (for first chapter optimization)
  if (cachedChapter.content != null && cachedChapter.content!.isNotEmpty) {
    // Content already available, return it directly without API call
    return cachedChapter;
  }

  // Content not available, fetch from API
  final chapterId = cachedChapter.id;
  return await bookService.getChapterDetails(chapterId);
}
