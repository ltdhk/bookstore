import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/src/features/settings/data/theme_provider.dart';
import 'package:book_store/src/features/reader/providers/chapter_provider.dart';
import 'package:book_store/src/features/reader/data/models/chapter_vo.dart';
import 'package:book_store/src/features/reader/data/reading_progress_service.dart';
import 'package:book_store/src/features/bookshelf/providers/bookshelf_provider.dart';
import 'package:book_store/src/features/subscription/presentation/subscription_dialog.dart';
import 'package:book_store/src/features/subscription/providers/subscription_provider.dart';
import 'package:book_store/src/features/auth/providers/auth_provider.dart';
import 'package:book_store/src/features/passcode/providers/passcode_provider.dart';
import 'package:book_store/src/features/passcode/data/passcode_api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  double _fontSize = 18.0;
  Color _backgroundColor = Colors.white;
  double _brightness = 0.5;
  bool _eyeProtectionMode = false;
  bool _showToolbars = true;
  bool _isInBookshelf = false;
  final ScrollController _scrollController = ScrollController();
  final ReadingProgressService _progressService = ReadingProgressService();
  Timer? _saveProgressTimer;
  bool _isRestoringScroll = false;
  bool _hasLoadedProgress = false;
  bool _isChaptersSortedAscending = true;
  bool _hasAutoNavigated = false; // Flag to prevent multiple auto-navigations
  bool _isLoadingNextChapter = false; // Flag for loading next chapter at bottom
  ChapterVO? _cachedChapter; // Cache current chapter content
  int _cachedChapterIndex = -1; // Cache current chapter index

  final double _defaultFontSize = 18.0;

  // Cache book info for bookshelf operations
  String _bookTitle = '';
  String _bookAuthor = '';
  String _bookCoverUrl = '';
  String _bookCategory = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadReaderSettings();
    _checkBookshelfStatus();
    _trackPasscodeUsage();
  }

  /// Track passcode 'open' action when opening a book via passcode
  Future<void> _trackPasscodeUsage() async {
    final bookId = int.parse(widget.bookId);
    final passcodeContext = ref.read(activePasscodeContextProvider);

    // Only track if this book was opened via passcode
    if (passcodeContext != null && passcodeContext.bookId == bookId) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userIdStr = prefs.getString('user_id');
        final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
        final apiService = ref.read(passcodeApiServiceProvider);
        await apiService.trackOpen(passcodeId: passcodeContext.passcodeId, userId: userId);
        debugPrint('Passcode open action tracked for book $bookId, userId: $userId');
      } catch (e) {
        // Log error but don't block user from reading
        debugPrint('Failed to track passcode open: $e');
      }
    }
  }

  /// Check if book is in bookshelf (from local storage)
  void _checkBookshelfStatus() {
    // Use local bookshelf provider to check status
    final isInShelf = ref.read(isBookInBookshelfProvider(widget.bookId));
    setState(() {
      _isInBookshelf = isInShelf;
    });
  }

  /// Load saved reading progress and restore position
  Future<void> _loadReadingProgress() async {
    if (_hasLoadedProgress) return;
    _hasLoadedProgress = true;

    final bookId = int.parse(widget.bookId);
    final progress = await _progressService.getReadingProgress(bookId);

    if (progress != null && mounted) {
      // Set the current chapter index
      ref.read(currentChapterIndexProvider.notifier).setIndex(progress.chapterIndex);
    }
  }

  /// Restore scroll position after content is rendered
  Future<void> _restoreScrollPosition() async {
    if (_isRestoringScroll) return;

    final bookId = int.parse(widget.bookId);
    final progress = await _progressService.getReadingProgress(bookId);

    if (progress != null && mounted && _scrollController.hasClients) {
      _isRestoringScroll = true;

      // Wait for next frame to ensure content is rendered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(progress.scrollOffset);

          // Reset flag after a short delay
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _isRestoringScroll = false;
            }
          });
        }
      });
    }
  }

  Future<void> _loadReaderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('reader_font_size') ?? 18.0;
      _brightness = prefs.getDouble('reader_brightness') ?? 0.5;
      _eyeProtectionMode = prefs.getBool('reader_eye_protection') ?? false;

      // Load background color
      final colorIndex = prefs.getInt('reader_background_color') ?? 0;
      _backgroundColor = _getBackgroundColorByIndex(colorIndex);
    });
  }

  Future<void> _saveReaderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('reader_font_size', _fontSize);
    await prefs.setDouble('reader_brightness', _brightness);
    await prefs.setBool('reader_eye_protection', _eyeProtectionMode);
    await prefs.setInt('reader_background_color', _getBackgroundColorIndex(_backgroundColor));
  }

  Color _getBackgroundColorByIndex(int index) {
    switch (index) {
      case 0:
        return Colors.white;
      case 1:
        return const Color(0xFFE8E8E8); // Light Gray
      case 2:
        return const Color(0xFFC8E6C9); // Green
      case 3:
        return const Color(0xFFB3D9FF); // Blue
      case 4:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  int _getBackgroundColorIndex(Color color) {
    if (color == Colors.white) return 0;
    if (color == const Color(0xFFE8E8E8)) return 1;
    if (color == const Color(0xFFC8E6C9)) return 2;
    if (color == const Color(0xFFB3D9FF)) return 3;
    if (color == Colors.black) return 4;
    return 0;
  }

  @override
  void dispose() {
    _saveProgressTimer?.cancel();
    _saveCurrentProgress();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    // Hide toolbars when scrolling
    if (_scrollController.position.isScrollingNotifier.value) {
      if (_showToolbars) {
        setState(() {
          _showToolbars = false;
        });
      }
    }

    // Skip saving if we're restoring scroll position
    if (_isRestoringScroll) return;

    // Debounce save progress
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer(const Duration(seconds: 2), () {
      _saveCurrentProgress();
    });

    // Check if scrolled to bottom and auto-navigate to next chapter
    if (_scrollController.hasClients) {
      final position = _scrollController.position;
      final scrollPercentage = position.pixels / position.maxScrollExtent;

      // Pre-load next chapter when scrolled 85%
      if (scrollPercentage > 0.85) {
        _preloadNextChapter();
      }

      // Auto-navigate to next chapter when scrolled to bottom (99%)
      if (scrollPercentage > 0.99 && !_hasAutoNavigated) {
        _autoNavigateToNextChapter();
      }
    }
  }

  /// Save current reading progress
  Future<void> _saveCurrentProgress() async {
    if (!mounted || !_scrollController.hasClients) return;

    final bookId = int.parse(widget.bookId);
    final readerDataAsync = ref.read(readerDataProvider(bookId));

    readerDataAsync.whenData((readerData) async {
      final currentIndex = ref.read(currentChapterIndexProvider);
      if (currentIndex >= 0 && currentIndex < readerData.chapters.length) {
        final currentChapter = readerData.chapters[currentIndex];
        await _progressService.saveReadingProgress(
          bookId: bookId,
          chapterIndex: currentIndex,
          chapterId: currentChapter.id,
          scrollOffset: _scrollController.offset,
        );
      }
    });
  }

  /// Pre-load next chapter in background
  void _preloadNextChapter() {
    final bookId = int.parse(widget.bookId);
    final currentIndex = ref.read(currentChapterIndexProvider);

    // Pre-load next chapter content (ignore result)
    ref.read(chapterContentProvider(bookId, currentIndex + 1).future).ignore();
  }

  /// Auto-navigate to next chapter when scrolled to bottom
  void _autoNavigateToNextChapter() {
    // Prevent multiple auto-navigations
    if (_hasAutoNavigated) return;

    final bookId = int.parse(widget.bookId);
    final readerDataAsync = ref.read(readerDataProvider(bookId));

    readerDataAsync.whenData((readerData) {
      final currentIndex = ref.read(currentChapterIndexProvider);
      final chapters = readerData.chapters;

      // Check if there's a next chapter
      if (currentIndex < chapters.length - 1) {
        final nextChapter = chapters[currentIndex + 1];

        // If user can access next chapter, auto-navigate to it
        if (nextChapter.canAccess ?? nextChapter.isFree) {
          setState(() {
            _hasAutoNavigated = true;
          });
          _navigateToChapter(currentIndex + 1);
        }
        // If next chapter is locked, stay on current chapter (membership UI will show)
        // Don't auto-navigate to avoid interrupting the user
      }
    });
  }

  /// Navigate to a specific chapter
  void _navigateToChapter(int chapterIndex) {
    // Save current progress before switching
    _saveCurrentProgress();

    // Set loading state for bottom loading indicator
    setState(() {
      _isLoadingNextChapter = true;
      _hasAutoNavigated = false;
    });

    // Update current chapter index
    ref.read(currentChapterIndexProvider.notifier).setIndex(chapterIndex);

    // Reset scroll to top after a short delay to allow new content to load
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });

    // Pre-load adjacent chapters
    _preloadAdjacentChapters(chapterIndex);
  }

  /// Check if the current chapter is the last accessible chapter
  bool _isLastFreeChapter(List<ChapterVO> chapters, int currentIndex) {
    if (currentIndex < 0 || currentIndex >= chapters.length) return false;

    final currentChapter = chapters[currentIndex];

    // If current chapter is not accessible, it's not the last accessible chapter
    final canAccessCurrent = currentChapter.canAccess ?? currentChapter.isFree;
    if (!canAccessCurrent) return false;

    // Check if there's a next chapter and it's not accessible
    if (currentIndex < chapters.length - 1) {
      final nextChapter = chapters[currentIndex + 1];
      final canAccessNext = nextChapter.canAccess ?? nextChapter.isFree;
      return !canAccessNext;
    }

    return false;
  }

  /// Find the last accessible chapter index
  int _findLastFreeChapterIndex(List<ChapterVO> chapters) {
    for (int i = chapters.length - 1; i >= 0; i--) {
      final canAccess = chapters[i].canAccess ?? chapters[i].isFree;
      if (canAccess) {
        return i;
      }
    }
    return 0; // Return first chapter if no accessible chapters found
  }

  /// Pre-load previous and next chapters
  void _preloadAdjacentChapters(int currentIndex) {
    final bookId = int.parse(widget.bookId);

    // Pre-load next chapter (ignore result)
    ref.read(chapterContentProvider(bookId, currentIndex + 1).future).ignore();

    // Pre-load previous chapter (ignore result)
    if (currentIndex > 0) {
      ref.read(chapterContentProvider(bookId, currentIndex - 1).future).ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch all reader data at once
    final readerDataAsync = ref.watch(readerDataProvider(int.parse(widget.bookId)));

    // Use theme for non-reading areas
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Use custom background color for reading area
    final isReadingBgDark = _backgroundColor == Colors.black;
    final readingTextColor = isReadingBgDark ? Colors.white : Colors.black;

    return readerDataAsync.when(
      loading: () => Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: readingTextColor,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Text(
            'Error loading book: $error',
            style: TextStyle(color: readingTextColor),
          ),
        ),
      ),
      data: (readerData) => _buildReaderContent(context, readerData, isDarkTheme, isReadingBgDark, readingTextColor),
    );
  }

  Widget _buildReaderContent(
    BuildContext context,
    dynamic readerData,
    bool isDarkTheme,
    bool isReadingBgDark,
    Color readingTextColor,
  ) {
    final book = readerData.book;
    final chapters = readerData.chapters;
    final bookId = int.parse(widget.bookId);

    // Cache book info for bookshelf operations
    _bookTitle = book.title ?? 'Unknown';
    _bookAuthor = book.author ?? 'Unknown';
    _bookCoverUrl = book.coverUrl ?? '';
    _bookCategory = book.category ?? 'General';

    // Check if there are no chapters
    if (chapters.isEmpty) {
      return _buildEmptyChaptersView(context, book, isDarkTheme, isReadingBgDark, readingTextColor);
    }

    // Load reading progress on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReadingProgress();
    });

    final currentIndex = ref.watch(currentChapterIndexProvider);

    // Watch current chapter content
    final currentChapterAsync = ref.watch(chapterContentProvider(bookId, currentIndex));

    return currentChapterAsync.when(
      loading: () {
        // If we have cached chapter content, show it with bottom loading indicator
        if (_cachedChapter != null && _isLoadingNextChapter) {
          return _buildChapterView(
            context,
            book,
            chapters,
            _cachedChapter!,
            _cachedChapterIndex,
            isDarkTheme,
            isReadingBgDark,
            readingTextColor,
            isLoadingNext: true,
          );
        }
        // First load - show full screen loading
        return Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(
            child: CircularProgressIndicator(
              color: readingTextColor,
            ),
          ),
        );
      },
      error: (error, stack) => Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Text(
            'Error loading chapter: $error',
            style: TextStyle(color: readingTextColor),
          ),
        ),
      ),
      data: (currentChapter) {
        // Cache the current chapter for future use
        _cachedChapter = currentChapter;
        _cachedChapterIndex = currentIndex;
        _isLoadingNextChapter = false;

        return _buildChapterView(
          context,
          book,
          chapters,
          currentChapter,
          currentIndex,
          isDarkTheme,
          isReadingBgDark,
          readingTextColor,
        );
      },
    );
  }

  Widget _buildChapterView(
    BuildContext context,
    dynamic book,
    List<ChapterVO> chapters,
    ChapterVO currentChapter,
    int currentIndex,
    bool isDarkTheme,
    bool isReadingBgDark,
    Color readingTextColor, {
    bool isLoadingNext = false,
  }) {
    // Restore scroll position after content is rendered (only when not loading next)
    if (!isLoadingNext) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
      });
    }

    // Check if this is the last free chapter
    final isLastFreeChapter = _isLastFreeChapter(chapters, currentIndex);
    final hasNextChapter = currentIndex < chapters.length - 1;

    // Check if current chapter is not accessible (user is non-SVIP on paid chapter)
    final canAccessCurrentChapter = currentChapter.canAccess ?? currentChapter.isFree;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Content area
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showToolbars ? 60 : 0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show content only if user can access this chapter
                        if (canAccessCurrentChapter) ...[
                          // Chapter content with tap to toggle toolbars
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showToolbars = !_showToolbars;
                              });
                            },
                            child: Text(
                              currentChapter.content ?? 'No content available',
                              style: TextStyle(
                                fontSize: _fontSize,
                                color: readingTextColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                          // Show membership upgrade UI if this is the last free chapter
                          // Don't wrap with GestureDetector to prevent toolbar toggle
                          if (isLastFreeChapter && hasNextChapter) ...[
                            const SizedBox(height: 40),
                            _buildMembershipUpgradeSection(context, isDarkTheme, readingTextColor),
                          ],
                          // Show bottom loading indicator when loading next chapter
                          if (isLoadingNext) ...[
                            const SizedBox(height: 40),
                            _buildBottomLoadingIndicator(readingTextColor),
                          ],
                        ] else ...[
                          // User cannot access this chapter - show upgrade UI directly
                          const SizedBox(height: 40),
                          _buildMembershipUpgradeSection(context, isDarkTheme, readingTextColor),
                        ],
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showToolbars ? 80 : 0,
                ),
              ],
            ),

            // Top toolbar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showToolbars ? 0 : -60,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: readingTextColor),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        book.title ?? 'Chapter 1',
                        style: TextStyle(
                          color: readingTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top toolbar when scrolling (shows book name and author)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: !_showToolbars ? 0 : -60,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: _backgroundColor.withValues(alpha: 0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.title ?? '',
                        style: TextStyle(
                          color: readingTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      book.author ?? '',
                      style: TextStyle(
                        color: readingTextColor.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showToolbars ? 0 : -200,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bottom navigation icons (always show)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.format_list_bulleted,
                            color: readingTextColor,
                            size: 28,
                          ),
                          onPressed: () {
                            _showChapterDrawer(context, book, chapters);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.text_fields,
                            color: readingTextColor,
                            size: 28,
                          ),
                          onPressed: () {
                            _showSettingsDrawer(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                            color: readingTextColor,
                            size: 28,
                          ),
                          onPressed: () {
                            final themeController = ref.read(themeControllerProvider.notifier);
                            final currentTheme = ref.read(themeControllerProvider).value ?? ThemeMode.system;

                            // Toggle between light and dark
                            if (currentTheme == ThemeMode.dark) {
                              // Switch to light theme
                              themeController.updateThemeMode(ThemeMode.light);
                              // Set background to first color (white)
                              setState(() {
                                _backgroundColor = Colors.white;
                              });
                              _saveReaderSettings();
                            } else {
                              // Switch to dark theme
                              themeController.updateThemeMode(ThemeMode.dark);
                              // Set background to last color (black)
                              setState(() {
                                _backgroundColor = Colors.black;
                              });
                              _saveReaderSettings();
                            }
                          },
                        ),
                        IconButton(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.collections_bookmark_outlined,
                                color: readingTextColor,
                                size: 28,
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: _backgroundColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isInBookshelf ? Icons.check : Icons.add,
                                    color: readingTextColor,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            try {
                              if (_isInBookshelf) {
                                // Remove from bookshelf (local storage)
                                await ref.read(bookshelfProvider.notifier).removeBook(widget.bookId);
                                if (mounted) {
                                  setState(() {
                                    _isInBookshelf = false;
                                  });
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Removed from bookshelf'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                // Add to bookshelf (local storage)
                                await ref.read(bookshelfProvider.notifier).addBook(
                                      id: widget.bookId,
                                      title: _bookTitle,
                                      author: _bookAuthor,
                                      coverUrl: _bookCoverUrl,
                                      category: _bookCategory,
                                    );
                                if (mounted) {
                                  setState(() {
                                    _isInBookshelf = true;
                                  });
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to bookshelf'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update bookshelf: $e'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bgColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
          final textColor = isDarkTheme ? Colors.white : Colors.black;

          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Brightness control
                Row(
                  children: [
                    Icon(Icons.brightness_low, color: textColor, size: 24),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: textColor.withValues(alpha: 0.3),
                          inactiveTrackColor: textColor.withValues(alpha: 0.1),
                          thumbColor: textColor,
                          overlayColor: textColor.withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _brightness,
                          onChanged: (value) {
                            setState(() {
                              _brightness = value;
                            });
                            setModalState(() {
                              _brightness = value;
                            });
                            _saveReaderSettings();
                          },
                        ),
                      ),
                    ),
                    Icon(Icons.brightness_high, color: textColor, size: 24),
                  ],
                ),
                const SizedBox(height: 24),
                // Font size controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFontButton('A-', () {
                      setState(() {
                        if (_fontSize > 12) _fontSize -= 2;
                      });
                      _saveReaderSettings();
                    }),
                    _buildFontButton('A+', () {
                      setState(() {
                        if (_fontSize < 30) _fontSize += 2;
                      });
                      _saveReaderSettings();
                    }),
                    _buildFontButton('Default', () {
                      setState(() {
                        _fontSize = _defaultFontSize;
                      });
                      _saveReaderSettings();
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                // Eye protection mode
                InkWell(
                  onTap: () {
                    setState(() {
                      _eyeProtectionMode = !_eyeProtectionMode;
                    });
                    setModalState(() {
                      _eyeProtectionMode = !_eyeProtectionMode;
                    });
                    _saveReaderSettings();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Eye protection mode',
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                      Switch(
                        value: _eyeProtectionMode,
                        onChanged: (value) {
                          setState(() {
                            _eyeProtectionMode = value;
                          });
                          setModalState(() {
                            _eyeProtectionMode = value;
                          });
                          _saveReaderSettings();
                        },
                        activeTrackColor: textColor.withValues(alpha: 0.5),
                        activeThumbColor: textColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Background color label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Background Color Setting',
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Background color buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildColorButton(Colors.white, 'T'),
                    _buildColorButton(const Color(0xFFE8E8E8), 'T'),
                    _buildColorButton(const Color(0xFFC8E6C9), 'T'),
                    _buildColorButton(const Color(0xFFB3D9FF), 'T'),
                    _buildColorButton(Colors.black, 'T'),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyChaptersView(
    BuildContext context,
    dynamic book,
    bool isDarkTheme,
    bool isReadingBgDark,
    Color readingTextColor,
  ) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: _backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: readingTextColor),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      book.title ?? 'Book Reader',
                      style: TextStyle(
                        color: readingTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Empty state content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 80,
                      color: readingTextColor.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No chapters available',
                      style: TextStyle(
                        color: readingTextColor.withValues(alpha: 0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This book doesn\'t have any chapters yet',
                      style: TextStyle(
                        color: readingTextColor.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChapterDrawer(BuildContext context, dynamic book, List<ChapterVO> chapters) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final currentIndex = ref.read(currentChapterIndexProvider);

    // Sort chapters based on orderNum
    final sortedChapters = List<ChapterVO>.from(chapters);
    if (_isChaptersSortedAscending) {
      sortedChapters.sort((a, b) => a.orderNum.compareTo(b.orderNum));
    } else {
      sortedChapters.sort((a, b) => b.orderNum.compareTo(a.orderNum));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final bgColor = isDarkTheme ? const Color(0xFF1E1E1E) : Colors.white;
          final textColor = isDarkTheme ? Colors.white : Colors.black;

          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkTheme ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: book.coverUrl != null
                            ? CachedNetworkImage(
                                imageUrl: book.coverUrl!,
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book, size: 40),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book, size: 40),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.book, size: 40),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title ?? '',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author ?? '',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Chapter info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Text(
                        '${book.chapterCount ?? 0} Chapter${(book.chapterCount ?? 0) > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        book.completionStatus == 'completed' ? 'Complete' : 'Ongoing',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _isChaptersSortedAscending ? Icons.arrow_downward : Icons.arrow_upward,
                          color: textColor,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isChaptersSortedAscending = !_isChaptersSortedAscending;
                          });
                          Navigator.pop(context);
                          _showChapterDrawer(context, book, chapters);
                        },
                        tooltip: _isChaptersSortedAscending ? 'Sort Descending' : 'Sort Ascending',
                      ),
                    ],
                  ),
                ),
                // Chapter list
                Expanded(
                  child: sortedChapters.isEmpty
                      ? Center(
                          child: Text(
                            'No chapters available',
                            style: TextStyle(color: textColor.withValues(alpha: 0.5)),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: sortedChapters.length,
                          itemBuilder: (context, index) {
                            final chapter = sortedChapters[index];
                            final isLocked = !(chapter.canAccess ?? chapter.isFree);
                            // Find the actual index in the original chapters list
                            final actualChapterIndex = chapters.indexWhere((c) => c.id == chapter.id);
                            final isCurrent = actualChapterIndex == currentIndex;

                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                if (isLocked) {
                                  // Navigate to last free chapter if clicking on a paid chapter
                                  final lastFreeIndex = _findLastFreeChapterIndex(chapters);
                                  _navigateToChapter(lastFreeIndex);

                                  // Show a message to the user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('This chapter is locked. Subscribe to unlock.'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  _navigateToChapter(actualChapterIndex);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDarkTheme ? Colors.grey[800]! : Colors.grey[100]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chapter.title,
                                        style: TextStyle(
                                          color: isLocked
                                              ? textColor.withValues(alpha: 0.3)
                                              : isCurrent
                                                  ? const Color(0xFFE91E63)
                                                  : textColor,
                                          fontSize: 16,
                                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (isLocked)
                                      Icon(
                                        Icons.lock_outline,
                                        color: textColor.withValues(alpha: 0.3),
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFontButton(String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final textColor = isDarkTheme ? Colors.white : Colors.black;
    final bgColor = isDarkTheme ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, String label) {
    final isSelected = _backgroundColor == color;
    final labelColor = color == Colors.white || color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = color;
        });
        _saveReaderSettings();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE91E63)
                : (color == Colors.white ? Colors.grey[300]! : color),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Show login dialog (same as profile screen)
  void _showLoginDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF3D7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Novel Master',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            // Login with Apple button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Apple login
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log in via apple',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Login with Google button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Google login
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log in via google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Login with Email button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log in via Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Agreement text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
                children: const [
                  TextSpan(text: 'When you log in, we will assume that you have read and agreed to the\n'),
                  TextSpan(
                    text: 'User Agreement',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' & '),
                  TextSpan(
                    text: 'Privacy Agreement',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }

  /// Show subscription dialog (check login first)
  void _showSubscriptionDialog(BuildContext context) {
    // Check if user is logged in
    final authState = ref.read(authProvider);

    authState.whenOrNull(
      data: (user) {
        if (user == null) {
          // User not logged in, show login dialog
          _showLoginDialog(context);
        } else {
          // User logged in, show subscription dialog
          showDialog(
            context: context,
            builder: (context) => SubscriptionDialog(
              sourceBookId: int.tryParse(widget.bookId),
              sourceEntry: 'reader',
            ),
          ).then((result) {
            // If subscription was successful, refresh chapter provider
            if (result == true) {
              final bookId = int.parse(widget.bookId);
              ref.invalidate(readerDataProvider(bookId));
              ref.invalidate(chapterContentProvider(bookId, ref.read(currentChapterIndexProvider)));
            }
          });
        }
      },
    );
  }

  /// Build membership upgrade section
  Widget _buildMembershipUpgradeSection(BuildContext context, bool isDarkTheme, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SVIP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'SVIP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Unlock all chapters',
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'Subscribe to continue reading and enjoy unlimited access to all premium content',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Recharge button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSubscriptionDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Choose Your Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom loading indicator for next chapter
  Widget _buildBottomLoadingIndicator(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading next chapter...',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

}
