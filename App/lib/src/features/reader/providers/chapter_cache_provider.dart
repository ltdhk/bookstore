import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/home/data/book_api_service.dart';
import 'package:novelpop/src/features/reader/data/models/chapter_vo.dart';
import 'package:novelpop/src/features/reader/data/models/reader_data.dart';
import 'package:novelpop/src/features/reader/providers/chapter_provider.dart';

part 'chapter_cache_provider.g.dart';

/// State for seamless chapter caching
class ChapterCacheState {
  /// Loaded chapters with content: index -> chapter
  final Map<int, ChapterVO> loadedChapters;

  /// Current center chapter index (the chapter user is reading)
  final int currentCenterIndex;

  /// Total number of chapters
  final int totalChapters;

  /// Whether initialization is complete
  final bool isInitialized;

  /// Loading state for chapters
  final Set<int> loadingChapters;

  /// Chapters that failed to load
  final Set<int> failedChapters;

  const ChapterCacheState({
    this.loadedChapters = const {},
    this.currentCenterIndex = 0,
    this.totalChapters = 0,
    this.isInitialized = false,
    this.loadingChapters = const {},
    this.failedChapters = const {},
  });

  ChapterCacheState copyWith({
    Map<int, ChapterVO>? loadedChapters,
    int? currentCenterIndex,
    int? totalChapters,
    bool? isInitialized,
    Set<int>? loadingChapters,
    Set<int>? failedChapters,
  }) {
    return ChapterCacheState(
      loadedChapters: loadedChapters ?? this.loadedChapters,
      currentCenterIndex: currentCenterIndex ?? this.currentCenterIndex,
      totalChapters: totalChapters ?? this.totalChapters,
      isInitialized: isInitialized ?? this.isInitialized,
      loadingChapters: loadingChapters ?? this.loadingChapters,
      failedChapters: failedChapters ?? this.failedChapters,
    );
  }

  /// Get chapters in render window (prev, current, next)
  List<int> getRenderWindowIndices() {
    final indices = <int>[];

    // Previous chapter
    if (currentCenterIndex > 0) {
      indices.add(currentCenterIndex - 1);
    }

    // Current chapter
    indices.add(currentCenterIndex);

    // Next chapter
    if (currentCenterIndex < totalChapters - 1) {
      indices.add(currentCenterIndex + 1);
    }

    return indices;
  }

  /// Get chapters ready for rendering (with content loaded)
  List<ChapterVO> getRenderableChapters() {
    final indices = getRenderWindowIndices();
    final chapters = <ChapterVO>[];

    for (final index in indices) {
      final chapter = loadedChapters[index];
      if (chapter != null) {
        chapters.add(chapter);
      }
    }

    return chapters;
  }

  /// Check if a chapter index is loaded
  bool isChapterLoaded(int index) {
    return loadedChapters.containsKey(index);
  }

  /// Check if a chapter is currently loading
  bool isChapterLoading(int index) {
    return loadingChapters.contains(index);
  }
}

/// Manages chapter caching for seamless reading experience
@riverpod
class ChapterCache extends _$ChapterCache {
  /// Maximum chapters to keep in memory
  static const int maxCachedChapters = 5;

  /// Number of chapters to render (prev + current + next)
  static const int renderWindowSize = 3;

  @override
  ChapterCacheState build(int bookId) {
    // Note: Auth state changes are handled by ReaderScreen, which invalidates
    // this provider when user logs in/out to refresh chapter access permissions
    return const ChapterCacheState();
  }

  /// Initialize cache at a specific chapter index
  Future<void> initializeAt(int centerIndex, ReaderData readerData) async {
    final chapters = readerData.chapters;
    if (chapters.isEmpty) return;

    // Clamp index to valid range
    final validIndex = centerIndex.clamp(0, chapters.length - 1);

    // Initialize state with chapter metadata
    state = state.copyWith(
      currentCenterIndex: validIndex,
      totalChapters: chapters.length,
      isInitialized: true,
    );

    // Load initial chapters (center and adjacent)
    await _loadChaptersAroundIndex(validIndex, readerData);
  }

  /// Update center chapter index (called when user scrolls to a new chapter)
  Future<void> updateCenter(int newIndex, ReaderData readerData) async {
    if (!state.isInitialized) return;
    if (newIndex < 0 || newIndex >= state.totalChapters) return;
    if (newIndex == state.currentCenterIndex) return;

    debugPrint('ChapterCache: Updating center from ${state.currentCenterIndex} to $newIndex');

    state = state.copyWith(currentCenterIndex: newIndex);

    // Load chapters around new center
    await _loadChaptersAroundIndex(newIndex, readerData);

    // Clean up distant chapters to save memory
    _cleanupDistantChapters(newIndex);
  }

  /// Load chapters around a specific index
  Future<void> _loadChaptersAroundIndex(int centerIndex, ReaderData readerData) async {
    final indicesToLoad = <int>[];

    // Determine which chapters to load
    for (int offset = -1; offset <= 1; offset++) {
      final index = centerIndex + offset;
      if (index >= 0 && index < state.totalChapters) {
        if (!state.isChapterLoaded(index) && !state.isChapterLoading(index)) {
          indicesToLoad.add(index);
        }
      }
    }

    if (indicesToLoad.isEmpty) return;

    // Mark chapters as loading
    state = state.copyWith(
      loadingChapters: {...state.loadingChapters, ...indicesToLoad},
    );

    // Load chapters concurrently
    await Future.wait(
      indicesToLoad.map((index) => _loadChapterContent(index, readerData)),
    );
  }

  /// Load a single chapter's content
  Future<void> _loadChapterContent(int index, ReaderData readerData) async {
    try {
      final chapters = readerData.chapters;
      if (index < 0 || index >= chapters.length) return;

      final chapterMeta = chapters[index];

      // Check if user can access this chapter
      final canAccess = chapterMeta.canAccess ?? chapterMeta.isFree;
      debugPrint('ChapterCache: Loading chapter $index, canAccess=$canAccess, isFree=${chapterMeta.isFree}, hasContent=${chapterMeta.content != null}');

      ChapterVO loadedChapter;

      if (!canAccess) {
        // User cannot access this chapter, use metadata only
        debugPrint('ChapterCache: Chapter $index - no access, using metadata only');
        loadedChapter = chapterMeta;
      } else if (chapterMeta.content != null && chapterMeta.content!.isNotEmpty) {
        // Content already available (e.g., first chapter from ReaderData)
        debugPrint('ChapterCache: Chapter $index - content already available');
        loadedChapter = chapterMeta;
      } else {
        // Fetch content from API
        debugPrint('ChapterCache: Chapter $index - fetching from API, chapterId=${chapterMeta.id}');
        final bookService = ref.read(bookApiServiceProvider);
        loadedChapter = await bookService.getChapterDetails(chapterMeta.id);
        debugPrint('ChapterCache: Chapter $index - API returned content length: ${loadedChapter.content?.length ?? 0}');
      }

      // Update state with loaded chapter
      final newLoadedChapters = Map<int, ChapterVO>.from(state.loadedChapters);
      newLoadedChapters[index] = loadedChapter;

      final newLoadingChapters = Set<int>.from(state.loadingChapters);
      newLoadingChapters.remove(index);

      state = state.copyWith(
        loadedChapters: newLoadedChapters,
        loadingChapters: newLoadingChapters,
      );

      debugPrint('ChapterCache: Loaded chapter $index: ${loadedChapter.title}');
    } catch (e) {
      debugPrint('ChapterCache: Failed to load chapter $index: $e');

      // Mark as failed
      final newLoadingChapters = Set<int>.from(state.loadingChapters);
      newLoadingChapters.remove(index);

      final newFailedChapters = Set<int>.from(state.failedChapters);
      newFailedChapters.add(index);

      state = state.copyWith(
        loadingChapters: newLoadingChapters,
        failedChapters: newFailedChapters,
      );
    }
  }

  /// Remove chapters that are too far from current reading position
  void _cleanupDistantChapters(int centerIndex) {
    if (state.loadedChapters.length <= maxCachedChapters) return;

    final newLoadedChapters = Map<int, ChapterVO>.from(state.loadedChapters);
    final indicesToRemove = <int>[];

    // Find chapters that are too far from center
    for (final index in newLoadedChapters.keys) {
      final distance = (index - centerIndex).abs();
      if (distance > 2) {
        indicesToRemove.add(index);
      }
    }

    // Sort by distance and remove farthest first
    indicesToRemove.sort((a, b) =>
      (b - centerIndex).abs().compareTo((a - centerIndex).abs())
    );

    for (final index in indicesToRemove) {
      if (newLoadedChapters.length <= maxCachedChapters) break;
      newLoadedChapters.remove(index);
      debugPrint('ChapterCache: Removed distant chapter $index');
    }

    state = state.copyWith(loadedChapters: newLoadedChapters);
  }

  /// Get chapter by index
  ChapterVO? getChapter(int index) {
    return state.loadedChapters[index];
  }

  /// Force reload a chapter (e.g., after subscription)
  Future<void> reloadChapter(int index, ReaderData readerData) async {
    // Remove from cache
    final newLoadedChapters = Map<int, ChapterVO>.from(state.loadedChapters);
    newLoadedChapters.remove(index);

    final newFailedChapters = Set<int>.from(state.failedChapters);
    newFailedChapters.remove(index);

    state = state.copyWith(
      loadedChapters: newLoadedChapters,
      failedChapters: newFailedChapters,
    );

    // Reload
    await _loadChapterContent(index, readerData);
  }

  /// Clear all cache
  void clearCache() {
    state = const ChapterCacheState();
  }
}

/// Provider to track chapter boundaries (scroll positions)
@riverpod
class ChapterBoundaries extends _$ChapterBoundaries {
  @override
  Map<int, ChapterBoundary> build(int bookId) {
    return {};
  }

  /// Update boundary for a chapter
  void updateBoundary(int chapterIndex, double startOffset, double endOffset) {
    final newBoundaries = Map<int, ChapterBoundary>.from(state);
    newBoundaries[chapterIndex] = ChapterBoundary(
      chapterIndex: chapterIndex,
      startOffset: startOffset,
      endOffset: endOffset,
    );
    state = newBoundaries;
  }

  /// Find which chapter contains a scroll offset
  int? findChapterAtOffset(double offset) {
    for (final boundary in state.values) {
      if (boundary.containsOffset(offset)) {
        return boundary.chapterIndex;
      }
    }
    return null;
  }

  /// Clear all boundaries
  void clearBoundaries() {
    state = {};
  }
}

/// Represents the scroll boundaries of a chapter
class ChapterBoundary {
  final int chapterIndex;
  final double startOffset;
  final double endOffset;

  const ChapterBoundary({
    required this.chapterIndex,
    required this.startOffset,
    required this.endOffset,
  });

  bool containsOffset(double offset) {
    return offset >= startOffset && offset <= endOffset;
  }

  double get height => endOffset - startOffset;

  @override
  String toString() {
    return 'ChapterBoundary(index: $chapterIndex, start: $startOffset, end: $endOffset)';
  }
}
