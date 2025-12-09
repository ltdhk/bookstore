import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'package:novelpop/src/features/settings/data/theme_provider.dart';
import 'package:novelpop/src/features/reader/providers/chapter_provider.dart';
import 'package:novelpop/src/features/reader/providers/chapter_cache_provider.dart';
import 'package:novelpop/src/features/reader/data/models/chapter_vo.dart';
import 'package:novelpop/src/features/reader/data/reading_progress_service.dart';
import 'package:novelpop/src/features/bookshelf/providers/bookshelf_provider.dart';
import 'package:novelpop/src/features/subscription/utils/subscription_flow_helper.dart';
import 'package:novelpop/src/features/passcode/providers/passcode_provider.dart';
import 'package:novelpop/src/features/passcode/data/passcode_api_service.dart';
import 'package:novelpop/src/features/reading_history/providers/reading_history_provider.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  // Reader settings
  double _fontSize = 18.0;
  Color _backgroundColor = Colors.white;
  double _brightness = 0.5;
  bool _eyeProtectionMode = false;
  bool _showToolbars = true;
  bool _isInBookshelf = false;
  bool _isChaptersSortedAscending = true;

  // Scroll management
  final ScrollController _scrollController = ScrollController();
  final ReadingProgressService _progressService = ReadingProgressService();
  Timer? _saveProgressTimer;

  // State flags
  bool _isRestoringScroll = false;
  bool _shouldRestoreScrollPosition = true;
  bool _isInitialized = false;

  // Chapter boundary tracking for seamless scrolling
  final Map<int, GlobalKey> _chapterKeys = {};
  final Map<int, double> _chapterHeights = {};
  int _visibleCenterChapter = 0;

  // Debounce for chapter detection to prevent oscillation
  Timer? _chapterDetectionDebounce;
  int _lastDetectedChapter = -1;

  final double _defaultFontSize = 18.0;

  // Cache book info for bookshelf operations
  String _bookTitle = '';
  String _bookAuthor = '';
  String? _bookCoverUrl;
  String _bookCategory = '';

  // iOS screenshot detection
  static const _iosScreenCaptureChannel = EventChannel('com.novelpop.app/screen_capture');
  StreamSubscription? _screenCaptureSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadReaderSettings();
    _checkBookshelfStatus();
    _trackPasscodeUsage();
    _enableScreenshotProtection();
  }

  /// Enable screenshot protection
  Future<void> _enableScreenshotProtection() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        debugPrint('Failed to enable screenshot protection: $e');
      }
    } else if (Platform.isIOS) {
      // Listen for iOS screenshot/screen recording events
      _screenCaptureSubscription = _iosScreenCaptureChannel.receiveBroadcastStream().listen(
        (event) {
          if (event == 'screenshot' || event == 'recording_started') {
            _showScreenshotWarning();
          }
        },
        onError: (error) {
          debugPrint('Screen capture detection error: $error');
        },
      );
    }
  }

  /// Disable screenshot protection when leaving the screen
  Future<void> _disableScreenshotProtection() async {
    if (Platform.isAndroid) {
      try {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      } catch (e) {
        debugPrint('Failed to disable screenshot protection: $e');
      }
    } else if (Platform.isIOS) {
      _screenCaptureSubscription?.cancel();
      _screenCaptureSubscription = null;
    }
  }

  /// Show warning dialog when screenshot is detected (iOS)
  void _showScreenshotWarning() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Detected'),
        content: const Text(
          'Screenshots of copyrighted content are not allowed. '
          'Please respect the intellectual property rights of the authors.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _saveProgressTimer?.cancel();
    _chapterDetectionDebounce?.cancel();
    _saveCurrentProgress();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _resetScreenBrightness();
    _disableScreenshotProtection();
    super.dispose();
  }

  /// Track passcode 'open' action when opening a book via passcode
  Future<void> _trackPasscodeUsage() async {
    final bookId = int.parse(widget.bookId);
    final passcodeContext = ref.read(activePasscodeContextProvider);

    if (passcodeContext != null && passcodeContext.bookId == bookId) {
      ref.read(activePasscodeContextProvider.notifier).updateLastAccessed(bookId);

      try {
        final prefs = await SharedPreferences.getInstance();
        final userIdStr = prefs.getString('user_id');
        final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
        final apiService = ref.read(passcodeApiServiceProvider);
        await apiService.trackOpen(passcodeId: passcodeContext.passcodeId, userId: userId);
        debugPrint('Passcode open action tracked for book $bookId, userId: $userId');
      } catch (e) {
        debugPrint('Failed to track passcode open: $e');
      }
    }
  }

  void _checkBookshelfStatus() {
    final isInShelf = ref.read(isBookInBookshelfProvider(widget.bookId));
    setState(() {
      _isInBookshelf = isInShelf;
    });
  }

  Future<void> _loadReaderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBrightness = prefs.getDouble('reader_brightness');
    final savedEyeProtection = prefs.getBool('reader_eye_protection') ?? false;

    setState(() {
      _fontSize = prefs.getDouble('reader_font_size') ?? 18.0;
      _eyeProtectionMode = savedEyeProtection;
      final colorIndex = prefs.getInt('reader_background_color') ?? 0;
      _backgroundColor = _getBackgroundColorByIndex(colorIndex);
    });

    if (savedBrightness != null) {
      _brightness = savedBrightness;
      await _setScreenBrightness(savedBrightness);
    } else {
      try {
        _brightness = await ScreenBrightness().current;
      } catch (e) {
        _brightness = 0.5;
      }
    }

    if (_eyeProtectionMode) {
      _applyEyeProtectionMode(true);
    }
  }

  Future<void> _setScreenBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
    } catch (e) {
      debugPrint('Failed to set brightness: $e');
    }
  }

  Future<void> _resetScreenBrightness() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      debugPrint('Failed to reset brightness: $e');
    }
  }

  void _applyEyeProtectionMode(bool enable) {
    if (enable) {
      setState(() {
        if (_backgroundColor == Colors.white) {
          _backgroundColor = const Color(0xFFF5F0E1);
        } else if (_backgroundColor == Colors.black) {
          _backgroundColor = const Color(0xFF1A1A14);
        }
      });
    } else {
      _loadBackgroundColorFromPrefs();
    }
  }

  Future<void> _loadBackgroundColorFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final colorIndex = prefs.getInt('reader_background_color') ?? 0;
    setState(() {
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
        return const Color(0xFFE8E8E8);
      case 2:
        return const Color(0xFFC8E6C9);
      case 3:
        return const Color(0xFFB3D9FF);
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

  void _handleScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      if (_showToolbars) {
        setState(() {
          _showToolbars = false;
        });
      }
    }

    if (_isRestoringScroll) return;

    // Debounce save progress
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer(const Duration(seconds: 2), () {
      _saveCurrentProgress();
    });

    // Detect current visible chapter and update center
    _detectVisibleChapter();
  }

  /// Detect which chapter is currently visible and update cache center
  void _detectVisibleChapter() {
    if (!_scrollController.hasClients || _chapterHeights.isEmpty) return;

    final scrollOffset = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    final viewportCenter = scrollOffset + viewportHeight / 2;

    // Find which chapter contains the viewport center
    double accumulatedHeight = 0;
    int? detectedChapter;

    final sortedIndices = _chapterHeights.keys.toList()..sort();
    for (final index in sortedIndices) {
      final height = _chapterHeights[index] ?? 0;
      if (viewportCenter >= accumulatedHeight && viewportCenter < accumulatedHeight + height) {
        detectedChapter = index;
        break;
      }
      accumulatedHeight += height;
    }

    // Only update if detection is stable (same chapter detected)
    if (detectedChapter != null && detectedChapter != _visibleCenterChapter) {
      // Debounce chapter detection to prevent oscillation
      _chapterDetectionDebounce?.cancel();
      _chapterDetectionDebounce = Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        // Re-check if still the same chapter after debounce
        if (detectedChapter == _lastDetectedChapter && detectedChapter != _visibleCenterChapter) {
          _visibleCenterChapter = detectedChapter!;
          ref.read(currentChapterIndexProvider.notifier).setIndex(detectedChapter);

          // Update chapter cache center (only for preloading, don't change render window)
          final bookId = int.parse(widget.bookId);
          final readerDataAsync = ref.read(readerDataProvider(bookId));
          readerDataAsync.whenData((readerData) {
            ref.read(chapterCacheProvider(bookId).notifier).updateCenter(detectedChapter!, readerData);
          });

          debugPrint('Detected visible chapter: $detectedChapter');
        }
      });

      _lastDetectedChapter = detectedChapter;
    }
  }

  Future<void> _saveCurrentProgress() async {
    if (!mounted || !_scrollController.hasClients) return;

    final bookId = int.parse(widget.bookId);
    final readerDataAsync = ref.read(readerDataProvider(bookId));

    readerDataAsync.whenData((readerData) async {
      final currentIndex = ref.read(currentChapterIndexProvider);
      if (currentIndex >= 0 && currentIndex < readerData.chapters.length) {
        final currentChapter = readerData.chapters[currentIndex];

        // Calculate scroll offset within current chapter
        double chapterOffset = _scrollController.offset;
        final sortedIndices = _chapterHeights.keys.toList()..sort();
        for (final index in sortedIndices) {
          if (index >= currentIndex) break;
          chapterOffset -= _chapterHeights[index] ?? 0;
        }

        await _progressService.saveReadingProgress(
          bookId: bookId,
          chapterIndex: currentIndex,
          chapterId: currentChapter.id,
          scrollOffset: chapterOffset.clamp(0, double.infinity),
        );
      }
    });
  }

  /// Initialize chapter cache with saved progress
  Future<void> _initializeChapterCache(ReaderData readerData) async {
    if (_isInitialized) return;
    _isInitialized = true;

    debugPrint('ReaderScreen: Initializing chapter cache');

    final bookId = int.parse(widget.bookId);
    final progress = await _progressService.getReadingProgress(bookId);

    int startIndex = 0;
    if (progress != null) {
      startIndex = progress.chapterIndex.clamp(0, readerData.chapters.length - 1);
    }

    _visibleCenterChapter = startIndex;
    ref.read(currentChapterIndexProvider.notifier).setIndex(startIndex);
    await ref.read(chapterCacheProvider(bookId).notifier).initializeAt(startIndex, readerData);

    // Restore scroll position after a short delay
    if (_shouldRestoreScrollPosition && progress != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition(startIndex, progress.scrollOffset);
      });
    }
  }

  /// Reinitialize after subscription success - reset state and reload
  void _reinitializeAfterSubscription() {
    final bookId = int.parse(widget.bookId);

    // Reset local state
    setState(() {
      _isInitialized = false;
      _chapterKeys.clear();
      _chapterHeights.clear();
      _lastDetectedChapter = -1;
    });

    // Invalidate providers to refresh data
    ref.invalidate(readerDataProvider(bookId));
    ref.invalidate(chapterCacheProvider(bookId));

    debugPrint('ReaderScreen: Reinitialized after subscription');
  }

  /// Restore scroll position to saved chapter and offset
  Future<void> _restoreScrollPosition(int chapterIndex, double chapterOffset) async {
    if (!mounted || !_scrollController.hasClients) return;
    _isRestoringScroll = true;

    // Wait for layout to complete
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted || !_scrollController.hasClients) {
      _isRestoringScroll = false;
      return;
    }

    // Calculate absolute scroll position
    double absoluteOffset = 0;
    final sortedIndices = _chapterHeights.keys.toList()..sort();
    for (final index in sortedIndices) {
      if (index >= chapterIndex) break;
      absoluteOffset += _chapterHeights[index] ?? 0;
    }
    absoluteOffset += chapterOffset;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = absoluteOffset.clamp(0.0, maxScroll);

    _scrollController.jumpTo(targetOffset);
    _shouldRestoreScrollPosition = false;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _isRestoringScroll = false;
      }
    });
  }

  /// Navigate to a specific chapter from chapter list
  void _navigateToChapter(int chapterIndex) {
    debugPrint('Navigating to chapter index: $chapterIndex');
    _saveCurrentProgress();
    _shouldRestoreScrollPosition = false;

    // Calculate scroll position for target chapter
    double targetOffset = 0;
    final sortedIndices = _chapterHeights.keys.toList()..sort();
    for (final index in sortedIndices) {
      if (index >= chapterIndex) break;
      targetOffset += _chapterHeights[index] ?? 0;
    }

    // Smooth scroll to chapter
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // Update state
    _visibleCenterChapter = chapterIndex;
    ref.read(currentChapterIndexProvider.notifier).setIndex(chapterIndex);

    final bookId = int.parse(widget.bookId);
    final readerDataAsync = ref.read(readerDataProvider(bookId));
    readerDataAsync.whenData((readerData) {
      ref.read(chapterCacheProvider(bookId).notifier).updateCenter(chapterIndex, readerData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final readerDataAsync = ref.watch(readerDataProvider(int.parse(widget.bookId)));
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final isReadingBgDark = _backgroundColor == Colors.black;
    final readingTextColor = isReadingBgDark ? Colors.white : Colors.black;

    return readerDataAsync.when(
      loading: () => _buildLoadingView(readingTextColor),
      error: (error, stack) => _buildErrorView(error, readingTextColor),
      data: (readerData) => _buildReaderContent(context, readerData, isDarkTheme, isReadingBgDark, readingTextColor),
    );
  }

  Widget _buildLoadingView(Color readingTextColor) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(readingTextColor, 'Loading...'),
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: readingTextColor),
              ),
            ),
            _buildBottomToolbarPlaceholder(readingTextColor, []),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(Object error, Color readingTextColor) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Text(
          'Error loading book: $error',
          style: TextStyle(color: readingTextColor),
        ),
      ),
    );
  }

  Widget _buildReaderContent(
    BuildContext context,
    ReaderData readerData,
    bool isDarkTheme,
    bool isReadingBgDark,
    Color readingTextColor,
  ) {
    final book = readerData.book;
    final chapters = readerData.chapters;
    final bookId = int.parse(widget.bookId);

    _bookTitle = book.title;
    _bookAuthor = book.author;
    _bookCoverUrl = book.coverUrl;
    _bookCategory = book.category ?? 'General';

    if (chapters.isEmpty) {
      return _buildEmptyChaptersView(context, book, readingTextColor);
    }

    // Initialize chapter cache when not initialized
    if (!_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeChapterCache(readerData);
        ref.read(readingHistoryProvider.notifier).addOrUpdateHistory(
              bookId: widget.bookId,
              title: book.title,
              author: book.author,
              coverUrl: book.coverUrl,
            );
      });
    }

    // Watch chapter cache state
    final cacheState = ref.watch(chapterCacheProvider(bookId));
    final currentIndex = ref.watch(currentChapterIndexProvider);

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
                  child: _buildSeamlessReaderView(
                    readerData,
                    cacheState,
                    currentIndex,
                    readingTextColor,
                    isDarkTheme,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showToolbars ? 80 : 0,
                ),
              ],
            ),

            // Top toolbar
            _buildAnimatedTopToolbar(book, readingTextColor),

            // Mini top bar when scrolling
            _buildMiniTopBar(book, readingTextColor),

            // Bottom toolbar
            _buildAnimatedBottomToolbar(book, chapters, isDarkTheme, readingTextColor),
          ],
        ),
      ),
    );
  }

  /// Build seamless reader view with multiple chapters
  Widget _buildSeamlessReaderView(
    ReaderData readerData,
    ChapterCacheState cacheState,
    int currentIndex,
    Color readingTextColor,
    bool isDarkTheme,
  ) {
    final chapters = readerData.chapters;
    final loadedChapters = cacheState.loadedChapters;

    // Render all loaded chapters in order (stable, no jumping)
    // This prevents layout changes when currentIndex updates
    final renderIndices = loadedChapters.keys.toList()..sort();

    // If no chapters loaded yet, show loading for current chapter
    if (renderIndices.isEmpty) {
      renderIndices.add(currentIndex.clamp(0, chapters.length - 1));
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showToolbars = !_showToolbars;
        });
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final index in renderIndices)
              if (index >= 0 && index < chapters.length)
                _buildChapterSection(
                  index,
                  chapters[index],
                  loadedChapters[index],
                  cacheState.isChapterLoading(index),
                  readingTextColor,
                  isDarkTheme,
                  chapters,
                ),
          ],
        ),
      ),
    );
  }

  /// Build a single chapter section with title separator
  Widget _buildChapterSection(
    int index,
    ChapterVO chapterMeta,
    ChapterVO? loadedChapter,
    bool isLoading,
    Color readingTextColor,
    bool isDarkTheme,
    List<ChapterVO> allChapters,
  ) {
    // Create a key for this chapter to track its position
    _chapterKeys[index] ??= GlobalKey();

    final canAccess = chapterMeta.canAccess ?? chapterMeta.isFree;
    final content = loadedChapter?.content;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Track chapter height after layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = _chapterKeys[index];
          if (key?.currentContext != null) {
            final box = key!.currentContext!.findRenderObject() as RenderBox?;
            if (box != null && box.hasSize) {
              _chapterHeights[index] = box.size.height;
            }
          }
        });

        return Container(
          key: _chapterKeys[index],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter title separator
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterMeta.title,
                      style: TextStyle(
                        fontSize: _fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: readingTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 60,
                      color: readingTextColor.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),

              // Chapter content
              if (!canAccess)
                _buildPaywallSection(readingTextColor, isDarkTheme)
              else if (isLoading || content == null || content.isEmpty)
                _buildChapterLoadingIndicator(readingTextColor)
              else
                Text(
                  content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: readingTextColor,
                    height: 1.8,
                  ),
                ),

              // No need to show membership upgrade here - the next chapter's paywall section handles it

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChapterLoadingIndicator(Color readingTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: readingTextColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Loading chapter...',
              style: TextStyle(
                color: readingTextColor.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywallSection(Color readingTextColor, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: _buildMembershipUpgradeSection(context, isDarkTheme, readingTextColor),
    );
  }

  Widget _buildTopBar(Color readingTextColor, String title) {
    return Container(
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
              title,
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
    );
  }

  Widget _buildBottomToolbarPlaceholder(Color readingTextColor, List<ChapterVO> chapters) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (chapters.length > 3)
            Icon(Icons.format_list_bulleted, color: readingTextColor.withValues(alpha: 0.3), size: 28),
          Icon(Icons.text_fields, color: readingTextColor.withValues(alpha: 0.3), size: 28),
          Icon(Icons.dark_mode, color: readingTextColor.withValues(alpha: 0.3), size: 28),
          Icon(Icons.collections_bookmark_outlined, color: readingTextColor.withValues(alpha: 0.3), size: 28),
        ],
      ),
    );
  }

  Widget _buildAnimatedTopToolbar(dynamic book, Color readingTextColor) {
    return AnimatedPositioned(
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
    );
  }

  Widget _buildMiniTopBar(dynamic book, Color readingTextColor) {
    return AnimatedPositioned(
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
    );
  }

  Widget _buildAnimatedBottomToolbar(dynamic book, List<ChapterVO> chapters, bool isDarkTheme, Color readingTextColor) {
    return AnimatedPositioned(
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (chapters.length > 3)
              IconButton(
                icon: Icon(Icons.format_list_bulleted, color: readingTextColor, size: 28),
                onPressed: () => _showChapterDrawer(context, book, chapters),
              ),
            IconButton(
              icon: Icon(Icons.text_fields, color: readingTextColor, size: 28),
              onPressed: () => _showSettingsDrawer(context),
            ),
            IconButton(
              icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode, color: readingTextColor, size: 28),
              onPressed: () => _toggleTheme(),
            ),
            _buildBookshelfButton(readingTextColor),
          ],
        ),
      ),
    );
  }

  void _toggleTheme() {
    final themeController = ref.read(themeControllerProvider.notifier);
    final currentTheme = ref.read(themeControllerProvider).value ?? ThemeMode.system;

    if (currentTheme == ThemeMode.dark) {
      themeController.updateThemeMode(ThemeMode.light);
      setState(() {
        _backgroundColor = Colors.white;
      });
    } else {
      themeController.updateThemeMode(ThemeMode.dark);
      setState(() {
        _backgroundColor = Colors.black;
      });
    }
    _saveReaderSettings();
  }

  Widget _buildBookshelfButton(Color readingTextColor) {
    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.collections_bookmark_outlined, color: readingTextColor, size: 28),
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
            await ref.read(bookshelfProvider.notifier).removeBook(widget.bookId);
            if (mounted) {
              setState(() {
                _isInBookshelf = false;
              });
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Removed from bookshelf'), duration: Duration(seconds: 2)),
              );
            }
          } else {
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
                const SnackBar(content: Text('Added to bookshelf'), duration: Duration(seconds: 2)),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed to update bookshelf: $e'), duration: const Duration(seconds: 2)),
            );
          }
        }
      },
    );
  }

  Widget _buildEmptyChaptersView(BuildContext context, dynamic book, Color readingTextColor) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(readingTextColor, book.title ?? 'Book Reader'),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 80, color: readingTextColor.withValues(alpha: 0.3)),
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
                            setModalState(() {});
                            _setScreenBrightness(value);
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
                    final newValue = !_eyeProtectionMode;
                    setState(() {
                      _eyeProtectionMode = newValue;
                    });
                    setModalState(() {});
                    _applyEyeProtectionMode(newValue);
                    _saveReaderSettings();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Eye protection mode', style: TextStyle(color: textColor, fontSize: 16)),
                      Switch(
                        value: _eyeProtectionMode,
                        onChanged: (value) {
                          setState(() {
                            _eyeProtectionMode = value;
                          });
                          setModalState(() {});
                          _applyEyeProtectionMode(value);
                          _saveReaderSettings();
                        },
                        activeTrackColor: textColor.withValues(alpha: 0.5),
                        activeThumbColor: textColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Background color
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Background Color Setting',
                    style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
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

  void _showChapterDrawer(BuildContext context, dynamic book, List<ChapterVO> chapters) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final currentIndex = ref.read(currentChapterIndexProvider);

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
                      bottom: BorderSide(color: isDarkTheme ? Colors.grey[800]! : Colors.grey[200]!),
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
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author ?? '',
                              style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 14),
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
                        style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        book.completionStatus == 'completed' ? 'Complete' : 'Ongoing',
                        style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 14),
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
                          child: Text('No chapters available', style: TextStyle(color: textColor.withValues(alpha: 0.5))),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: sortedChapters.length,
                          itemBuilder: (context, index) {
                            final chapter = sortedChapters[index];
                            final isLocked = !(chapter.canAccess ?? chapter.isFree);
                            final actualChapterIndex = chapters.indexWhere((c) => c.id == chapter.id);
                            final isCurrent = actualChapterIndex == currentIndex;

                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                if (isLocked) {
                                  // Show subscription dialog for locked chapters
                                  final bookId = int.parse(widget.bookId);
                                  SubscriptionFlowHelper.showSubscriptionFlow(
                                    context: context,
                                    ref: ref,
                                    sourceBookId: bookId,
                                    sourceEntry: 'reader_chapter_list',
                                    onSuccess: () => _reinitializeAfterSubscription(),
                                  );
                                } else {
                                  _navigateToChapter(actualChapterIndex);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: isDarkTheme ? Colors.grey[800]! : Colors.grey[100]!),
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
                                      Icon(Icons.lock_outline, color: textColor.withValues(alpha: 0.3), size: 20),
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
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, String label) {
    final isSelected = _backgroundColor == color;
    final labelColor = color == Colors.white || color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

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
            color: isSelected ? const Color(0xFFE91E63) : (color == Colors.white ? Colors.grey[300]! : color),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: labelColor, fontSize: 18, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
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
          Text(
            'Unlock all chapters',
            style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Subscribe to continue reading and enjoy unlimited access to all premium content',
            style: TextStyle(color: textColor.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final bookId = int.parse(widget.bookId);
                SubscriptionFlowHelper.showSubscriptionFlow(
                  context: context,
                  ref: ref,
                  sourceBookId: bookId,
                  sourceEntry: 'reader',
                  onSuccess: () => _reinitializeAfterSubscription(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
              ),
              child: const Text(
                'Choose Your Plan',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
