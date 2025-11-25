import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/features/home/data/book_api_service.dart';
import 'package:book_store/src/features/home/data/models/book_vo.dart';
import 'package:book_store/src/features/reader/data/models/chapter_vo.dart';

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

/// Combined data for reader screen (book info + chapter list without content)
class ReaderData {
  final BookVO book;
  final List<ChapterVO> chapters;

  ReaderData({
    required this.book,
    required this.chapters,
  });
}

/// Provider that fetches book metadata and chapter list
@riverpod
Future<ReaderData> readerData(Ref ref, int bookId) async {
  final bookService = ref.watch(bookApiServiceProvider);

  // Fetch book details and chapter list in parallel
  // Request to include first chapter content to reduce API calls
  final results = await Future.wait([
    bookService.getBookDetails(bookId),
    bookService.getBookChapters(bookId, includeFirstChapter: true),
  ]);

  final book = results[0] as BookVO;
  final chapters = results[1] as List<ChapterVO>;

  return ReaderData(
    book: book,
    chapters: chapters,
  );
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
