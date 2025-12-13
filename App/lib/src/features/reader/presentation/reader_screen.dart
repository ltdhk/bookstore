import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:no_screenshot/no_screenshot.dart';

import 'package:novelpop/src/features/settings/data/theme_provider.dart';
import 'package:novelpop/src/features/auth/providers/auth_provider.dart';
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
  // Screenshot protection
  final _noScreenshot = NoScreenshot.instance;

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
  bool? _lastHasValidSubscription; // Track subscription status to detect changes

  // 初始化锁：防止初始化期间章节检测和进度保存干扰
  bool _isInitializing = false;

  // 标记：订阅/登录状态变化后保持当前位置
  bool _keepCurrentPositionOnReinit = false;

  // 保存状态变化前的滚动位置，用于恢复
  double? _savedScrollOffsetBeforeReinit;

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

  /// 计算有效阅读位置：找到指定索引或之前最后一个可访问的章节
  /// 这确保我们只保存和恢复到用户实际能阅读的章节
  int _findEffectiveReadingPosition(List<ChapterVO> chapters, int targetIndex) {
    final clampedIndex = targetIndex.clamp(0, chapters.length - 1);

    // 从目标位置向前查找第一个可访问的章节
    for (int i = clampedIndex; i >= 0; i--) {
      final chapter = chapters[i];
      final canAccess = chapter.canAccess ?? chapter.isFree;
      if (canAccess) {
        return i;
      }
    }

    // 如果都不可访问，返回第一章（通常第一章免费）
    return 0;
  }

  /// 检查章节是否可访问
  bool _isChapterAccessible(ChapterVO chapter) {
    return chapter.canAccess ?? chapter.isFree;
  }

  /// 检查指定章节索引范围内的高度是否已全部计算完成
  /// 用于确保滚动位置计算的准确性
  bool _areChapterHeightsReady(int upToIndex) {
    for (int i = 0; i <= upToIndex; i++) {
      if (!_chapterHeights.containsKey(i)) {
        return false;
      }
    }
    return true;
  }

  /// 等待章节高度计算完成
  /// [upToIndex] 需要等待高度计算完成的最大章节索引
  /// 最多等待2秒，防止无限等待
  Future<bool> _waitForChapterHeights(int upToIndex) async {
    const maxAttempts = 40; // 40 * 50ms = 2秒
    int attempts = 0;

    while (attempts < maxAttempts && mounted) {
      if (_areChapterHeightsReady(upToIndex)) {
        debugPrint('ChapterHeights: Ready for chapters 0-$upToIndex after ${attempts * 50}ms');
        return true;
      }
      await Future.delayed(const Duration(milliseconds: 50));
      attempts++;
    }

    debugPrint('ChapterHeights: Timeout waiting for chapters 0-$upToIndex, available: ${_chapterHeights.keys.toList()}');
    return false;
  }

  String _bookAuthor = '';
  String? _bookCoverUrl;
  String _bookCategory = '';

  @override
  void initState() {
    super.initState();
    _enableScreenshotProtection();
    _scrollController.addListener(_handleScroll);
    _loadReaderSettings();
    _checkBookshelfStatus();
    _trackPasscodeUsage();
  }

  Future<void> _enableScreenshotProtection() async {
    await _noScreenshot.screenshotOff();
  }

  Future<void> _disableScreenshotProtection() async {
    await _noScreenshot.screenshotOn();
  }

  @override
  void dispose() {
    _disableScreenshotProtection();
    _saveProgressTimer?.cancel();
    _chapterDetectionDebounce?.cancel();
    // 强制保存进度（忽略 _isInitializing 标志）
    _forceSaveCurrentProgress();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _resetScreenBrightness();
    super.dispose();
  }

  /// 强制保存当前进度，用于 dispose 时
  /// 与 _saveCurrentProgress 不同，这个方法不检查 _isInitializing
  Future<void> _forceSaveCurrentProgress() async {
    if (!_scrollController.hasClients) return;

    final bookId = int.parse(widget.bookId);
    final readerDataAsync = ref.read(readerDataProvider(bookId));

    readerDataAsync.whenData((readerData) async {
      final chapters = readerData.chapters;
      if (chapters.isEmpty) return;

      // 使用 _visibleCenterChapter 作为当前章节（这个值始终保持在可访问章节）
      int currentIndex = _visibleCenterChapter.clamp(0, chapters.length - 1);

      // 再次验证章节可访问性
      if (!_isChapterAccessible(chapters[currentIndex])) {
        currentIndex = _findEffectiveReadingPosition(chapters, currentIndex);
      }

      final chapterToSave = chapters[currentIndex];

      // 计算章节内偏移
      double chapterOffset = 0;
      if (_chapterHeights.isNotEmpty) {
        chapterOffset = _scrollController.offset;
        final sortedIndices = _chapterHeights.keys.toList()..sort();
        for (final index in sortedIndices) {
          if (index >= currentIndex) break;
          chapterOffset -= _chapterHeights[index] ?? 0;
        }
        chapterOffset = chapterOffset.clamp(0, double.infinity);
      }

      await _progressService.saveReadingProgress(
        bookId: bookId,
        chapterIndex: currentIndex,
        chapterId: chapterToSave.id,
        scrollOffset: chapterOffset,
      );

      debugPrint('ForceSaveProgress: Saved at chapter $currentIndex, offset=$chapterOffset');
    });
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
    // 初始化期间不进行章节检测，避免与初始化逻辑冲突
    if (_isInitializing) return;
    if (!_scrollController.hasClients || _chapterHeights.isEmpty) return;

    // 检查当前可见区域相关章节的高度是否稳定
    // 只有当当前章节及相邻章节的高度都已计算时才进行检测
    // 这可以避免高度更新过程中的错误检测
    final currentCenter = _visibleCenterChapter;
    final minRequiredIndex = (currentCenter - 1).clamp(0, 999);
    final maxRequiredIndex = (currentCenter + 1).clamp(0, 999);

    // 检查相关章节高度是否已计算
    bool heightsStable = true;
    for (int i = minRequiredIndex; i <= maxRequiredIndex; i++) {
      if (_chapterHeights.containsKey(i)) continue;
      // 如果这个索引在已加载的章节范围内但高度未计算，说明不稳定
      final sortedIndices = _chapterHeights.keys.toList()..sort();
      if (sortedIndices.isNotEmpty && i >= sortedIndices.first && i <= sortedIndices.last) {
        heightsStable = false;
        break;
      }
    }

    if (!heightsStable) {
      debugPrint('DetectChapter: Heights not stable, skipping detection');
      return;
    }

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
          final bookId = int.parse(widget.bookId);
          final readerDataAsync = ref.read(readerDataProvider(bookId));

          readerDataAsync.whenData((readerData) {
            final chapter = readerData.chapters[detectedChapter!];
            final canAccess = _isChapterAccessible(chapter);

            if (canAccess) {
              // 可访问章节：正常更新位置
              _visibleCenterChapter = detectedChapter;
              ref.read(currentChapterIndexProvider.notifier).setIndex(detectedChapter);
              debugPrint('Detected visible chapter: $detectedChapter (accessible)');
            } else {
              // 不可访问章节：不更新 _visibleCenterChapter，保持在最后可访问位置
              // 这样进度保存时会保存最后可访问的章节
              debugPrint('Detected chapter $detectedChapter but not accessible, keeping position at $_visibleCenterChapter');
            }

            // 更新章节缓存中心用于预加载（无论是否可访问都更新）
            ref.read(chapterCacheProvider(bookId).notifier).updateCenter(detectedChapter, readerData);
          });
        }
      });

      _lastDetectedChapter = detectedChapter;
    }
  }

  Future<void> _saveCurrentProgress() async {
    // 初始化期间不保存进度
    if (_isInitializing) return;
    if (!mounted || !_scrollController.hasClients) return;

    final bookId = int.parse(widget.bookId);
    final readerDataAsync = ref.read(readerDataProvider(bookId));

    readerDataAsync.whenData((readerData) async {
      final chapters = readerData.chapters;
      int currentIndex = ref.read(currentChapterIndexProvider);

      if (currentIndex >= 0 && currentIndex < chapters.length) {
        // 确保只保存到可访问的章节
        // 如果当前章节不可访问，找到最后一个可访问的章节
        if (!_isChapterAccessible(chapters[currentIndex])) {
          currentIndex = _findEffectiveReadingPosition(chapters, currentIndex);
          debugPrint('SaveProgress: Adjusted to accessible chapter $currentIndex');
        }

        final chapterToSave = chapters[currentIndex];

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
          chapterId: chapterToSave.id,
          scrollOffset: chapterOffset.clamp(0, double.infinity),
        );

        debugPrint('SaveProgress: Saved progress at chapter $currentIndex, offset=$chapterOffset');
      }
    });
  }

  /// Initialize chapter cache with saved progress
  Future<void> _initializeChapterCache(ReaderData readerData) async {
    debugPrint('ReaderScreen: Initializing chapter cache, keepCurrentPosition=$_keepCurrentPositionOnReinit');

    // 设置初始化锁
    _isInitializing = true;
    _isInitialized = true;

    final bookId = int.parse(widget.bookId);
    final chapters = readerData.chapters;

    int startIndex;
    double scrollOffset = 0;

    if (_keepCurrentPositionOnReinit) {
      // 订阅/登录状态变化后：保持当前可见位置
      // 但需要验证当前位置是否可访问
      final currentPos = _visibleCenterChapter.clamp(0, chapters.length - 1);
      if (_isChapterAccessible(chapters[currentPos])) {
        startIndex = currentPos;
      } else {
        // 当前位置不可访问（比如订阅过期），回退到最后可访问章节
        startIndex = _findEffectiveReadingPosition(chapters, currentPos);
      }
      debugPrint('ReaderScreen: Using current position after state change, chapter=$startIndex, savedOffset=$_savedScrollOffsetBeforeReinit');
      _keepCurrentPositionOnReinit = false;
    } else {
      // 正常初始化：使用保存的进度
      final progress = await _progressService.getReadingProgress(bookId);

      if (progress != null) {
        final savedIndex = progress.chapterIndex.clamp(0, chapters.length - 1);

        // 验证保存的章节是否可访问
        if (_isChapterAccessible(chapters[savedIndex])) {
          startIndex = savedIndex;
          scrollOffset = progress.scrollOffset;
          debugPrint('ReaderScreen: Using saved progress, chapter=$startIndex, offset=$scrollOffset');
        } else {
          // 保存的章节不可访问，回退到最后可访问章节
          startIndex = _findEffectiveReadingPosition(chapters, savedIndex);
          scrollOffset = 0; // 章节变了，重置滚动偏移
          debugPrint('ReaderScreen: Saved chapter $savedIndex not accessible, adjusted to chapter $startIndex');
        }
      } else {
        startIndex = 0;
        debugPrint('ReaderScreen: No saved progress, starting from chapter 0');
      }
    }

    // 一次性设置所有状态
    _visibleCenterChapter = startIndex;
    ref.read(currentChapterIndexProvider.notifier).setIndex(startIndex);

    // 检查 chapterCache 是否已初始化
    final cacheState = ref.read(chapterCacheProvider(bookId));
    if (cacheState.isInitialized && _savedScrollOffsetBeforeReinit != null) {
      // 权限变化后的重新加载：保持缓存结构，但重新加载所有章节内容
      // 这样可以避免 UI 闪烁，同时获取新权限下的内容
      debugPrint('ReaderScreen: Reloading chapters with new permissions');
      await ref.read(chapterCacheProvider(bookId).notifier).reloadAllChapters(readerData);
    } else if (cacheState.isInitialized) {
      // 缓存已初始化但不是权限变化，只更新中心位置
      await ref.read(chapterCacheProvider(bookId).notifier).updateCenter(startIndex, readerData);
    } else {
      // 缓存未初始化，完整初始化
      await ref.read(chapterCacheProvider(bookId).notifier).initializeAt(startIndex, readerData);
    }

    // 判断是否需要恢复滚动位置
    final savedOffset = _savedScrollOffsetBeforeReinit;
    final needsScrollRestore = (_shouldRestoreScrollPosition && scrollOffset > 0) || savedOffset != null;

    if (needsScrollRestore) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (savedOffset != null) {
          // 状态变化后恢复：直接跳转到保存的绝对滚动位置
          await _restoreAbsoluteScrollPosition(savedOffset);
          _savedScrollOffsetBeforeReinit = null;
        } else {
          // 正常恢复：基于章节和偏移计算位置
          await _restoreScrollPosition(startIndex, scrollOffset);
        }

        // 滚动恢复完成后解除初始化锁
        // 由于滚动恢复方法内部已经等待了高度计算，这里只需短暂延迟
        if (mounted) {
          _isInitializing = false;
          debugPrint('ReaderScreen: Initialization complete (with scroll restore)');
        }
      });
    } else {
      // 没有滚动恢复时，等待初始章节高度计算完成后解除初始化锁
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // 等待起始章节及相邻章节的高度计算完成
        final waitIndex = (startIndex + 1).clamp(0, chapters.length - 1);
        await _waitForChapterHeights(waitIndex);

        if (mounted) {
          _isInitializing = false;
          debugPrint('ReaderScreen: Initialization complete (no scroll restore)');
        }
      });
    }
  }

  /// Reinitialize after subscription success - reset state and reload
  void _reinitializeAfterSubscription() {
    final bookId = int.parse(widget.bookId);

    debugPrint('ReaderScreen: Reinitializing after subscription success');

    // 保持当前位置，用户刚订阅成功应该继续阅读当前位置
    _keepCurrentPositionOnReinit = true;

    // 保存当前滚动位置
    if (_scrollController.hasClients) {
      _savedScrollOffsetBeforeReinit = _scrollController.offset;
      debugPrint('ReaderScreen: Saved scroll offset before subscription reinit: $_savedScrollOffsetBeforeReinit');
    }

    setState(() {
      _isInitialized = false;
      _lastDetectedChapter = -1;
    });

    // 只刷新 readerData 获取新权限，不清空章节缓存（避免闪烁）
    ref.invalidate(readerDataProvider(bookId));
    // 不 invalidate chapterCacheProvider，保持已加载的章节内容
  }

  /// Restore scroll position to an absolute offset (used after auth/subscription changes)
  Future<void> _restoreAbsoluteScrollPosition(double absoluteOffset) async {
    if (!mounted || !_scrollController.hasClients) return;
    _isRestoringScroll = true;

    debugPrint('RestoreAbsoluteScroll: Starting restore to offset $absoluteOffset');

    // 等待当前可见章节的高度计算完成
    // 对于绝对位置恢复，等待当前中心章节及相邻章节
    final centerIndex = _visibleCenterChapter;
    final waitIndex = (centerIndex + 1).clamp(0, 999); // 等待中心章节和下一章节
    await _waitForChapterHeights(waitIndex);

    if (!mounted || !_scrollController.hasClients) {
      _isRestoringScroll = false;
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = absoluteOffset.clamp(0.0, maxScroll);

    debugPrint('RestoreAbsoluteScroll: Jumping to offset $targetOffset (requested: $absoluteOffset, max: $maxScroll)');
    _scrollController.jumpTo(targetOffset);

    // 短暂延迟后解除恢复标志并保存进度
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isRestoringScroll = false;
        debugPrint('RestoreAbsoluteScroll: Restore complete');
        // 滚动恢复完成后，触发一次进度保存
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _saveCurrentProgress();
          }
        });
      }
    });
  }

  /// Restore scroll position to saved chapter and offset
  Future<void> _restoreScrollPosition(int chapterIndex, double chapterOffset) async {
    if (!mounted || !_scrollController.hasClients) return;
    _isRestoringScroll = true;

    debugPrint('RestoreScroll: Starting restore to chapter $chapterIndex, offset $chapterOffset');

    // 等待目标章节及之前所有章节的高度计算完成
    // 这确保滚动位置计算准确
    final heightsReady = await _waitForChapterHeights(chapterIndex);

    if (!mounted || !_scrollController.hasClients) {
      _isRestoringScroll = false;
      return;
    }

    if (!heightsReady) {
      debugPrint('RestoreScroll: Heights not ready, using available data');
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

    debugPrint('RestoreScroll: Jumping to offset $targetOffset (calculated: $absoluteOffset, max: $maxScroll)');
    _scrollController.jumpTo(targetOffset);
    _shouldRestoreScrollPosition = false;

    // 短暂延迟后解除恢复标志，允许正常滚动处理
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _isRestoringScroll = false;
        debugPrint('RestoreScroll: Restore complete');
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
    final bookId = int.parse(widget.bookId);

    // Listen to auth state changes to refresh data when user logs in/out
    // This ensures chapter access permissions are refreshed correctly
    ref.listen(authProvider, (previous, next) {
      final previousUserId = previous?.value?.id;
      final nextUserId = next.value?.id;
      if (previousUserId != nextUserId) {
        debugPrint('ReaderScreen: Auth state changed (user: $previousUserId -> $nextUserId)');

        // 如果页面已初始化，保持当前位置和滚动偏移
        final wasInitialized = _isInitialized;
        if (wasInitialized) {
          _keepCurrentPositionOnReinit = true;
          // 保存当前滚动位置
          if (_scrollController.hasClients) {
            _savedScrollOffsetBeforeReinit = _scrollController.offset;
            debugPrint('ReaderScreen: Saved scroll offset: $_savedScrollOffsetBeforeReinit');
          }
        }

        // 只刷新 readerData 获取新权限，不清空章节缓存（避免闪烁）
        ref.invalidate(readerDataProvider(bookId));
        // 只有首次加载时才需要 invalidate chapterCache
        if (!wasInitialized) {
          ref.invalidate(chapterCacheProvider(bookId));
        }

        setState(() {
          _isInitialized = false;
          _lastDetectedChapter = -1;
        });
      }
    });

    final readerDataAsync = ref.watch(readerDataProvider(bookId));
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

    // Watch chapter cache state first to check if it needs reinitialization
    final cacheState = ref.watch(chapterCacheProvider(bookId));
    final currentIndex = ref.watch(currentChapterIndexProvider);

    // Debug: Log chapter access status
    debugPrint('ReaderScreen: Building content, _isInitialized=$_isInitialized, cacheInitialized=${cacheState.isInitialized}, hasValidSubscription=${readerData.hasValidSubscription}, lastSubscription=$_lastHasValidSubscription');
    for (int i = 0; i < chapters.length && i < 5; i++) {
      debugPrint('ReaderScreen: Chapter $i - canAccess=${chapters[i].canAccess}, isFree=${chapters[i].isFree}');
    }

    // Check if subscription status changed (e.g., user logged in with SVIP)
    // This ensures we reinitialize with the new access permissions
    final subscriptionChanged = _lastHasValidSubscription != null &&
        _lastHasValidSubscription != readerData.hasValidSubscription;

    // Initialize chapter cache when:
    // 1. Local _isInitialized is false (first load), OR
    // 2. Cache was invalidated (cacheState.isInitialized is false), OR
    // 3. Subscription status changed (need to reload with new permissions)
    final needsInitialization = !_isInitialized || !cacheState.isInitialized || subscriptionChanged;
    if (needsInitialization) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('ReaderScreen: Need initialization, _isInitialized=$_isInitialized, cacheInitialized=${cacheState.isInitialized}, subscriptionChanged=$subscriptionChanged');

        // Invalidate cache if subscription changed to clear old data
        if (subscriptionChanged) {
          debugPrint('ReaderScreen: Subscription changed, keeping current position');
          // 订阅状态变化时保持当前位置
          if (_isInitialized) {
            _keepCurrentPositionOnReinit = true;
          }
          ref.invalidate(chapterCacheProvider(bookId));
        }

        // 记录是否是首次初始化（用于添加阅读历史）
        final isFirstInit = !_isInitialized;

        _initializeChapterCache(readerData);

        if (isFirstInit) {
          ref.read(readingHistoryProvider.notifier).addOrUpdateHistory(
                bookId: widget.bookId,
                title: book.title,
                author: book.author,
                coverUrl: book.coverUrl,
              );
        }
      });
    }

    // Update last subscription status
    _lastHasValidSubscription = readerData.hasValidSubscription;

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

    // 关键修复：初始化期间，等待当前章节及之前的章节都加载完成后再渲染
    // 这防止了章节乱跳问题：
    // - 例如保存进度在章节2，需要加载章节1,2,3
    // - 如果章节3先完成（无权限不需要API调用），直接渲染会先显示章节3
    // - 然后章节1,2加载完后插入前面，导致页面跳转
    // 解决方案：初始化期间只在所有前置章节加载完成后才渲染

    final sortedIndices = loadedChapters.keys.toList()..sort();
    final renderIndices = <int>[];

    if (sortedIndices.isNotEmpty) {
      if (_isInitializing) {
        // 初始化期间：必须等待当前章节及之前所有章节加载完成
        // 检查从第一个已加载章节到当前章节是否连续
        final windowStart = sortedIndices.first;
        final targetChapter = _visibleCenterChapter;

        // 检查从 windowStart 到 targetChapter 的章节是否都已加载
        bool allPreChaptersLoaded = true;
        for (int i = windowStart; i <= targetChapter; i++) {
          if (!loadedChapters.containsKey(i)) {
            allPreChaptersLoaded = false;
            break;
          }
        }

        if (allPreChaptersLoaded) {
          // 所有前置章节都已加载，可以渲染连续的章节
          int expectedIndex = windowStart;
          for (final index in sortedIndices) {
            if (index == expectedIndex) {
              renderIndices.add(index);
              expectedIndex++;
            } else {
              break;
            }
          }
        }
        // 如果前置章节未完成，renderIndices 保持为空，显示 loading
      } else {
        // 非初始化期间：正常渲染所有连续章节
        final windowStart = sortedIndices.first;
        int expectedIndex = windowStart;
        for (final index in sortedIndices) {
          if (index == expectedIndex) {
            renderIndices.add(index);
            expectedIndex++;
          } else {
            break;
          }
        }
      }
    }

    // If no chapters ready to render, show loading for current chapter
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
        // 在 await 之前获取 notifier 引用，避免 widget 销毁后使用 ref
        final bookshelfNotifier = ref.read(bookshelfProvider.notifier);
        final bookId = widget.bookId;
        final bookTitle = _bookTitle;
        final bookAuthor = _bookAuthor;
        final bookCoverUrl = _bookCoverUrl;
        final bookCategory = _bookCategory;
        final wasInBookshelf = _isInBookshelf;

        try {
          if (wasInBookshelf) {
            await bookshelfNotifier.removeBook(bookId);
            if (mounted) {
              setState(() {
                _isInBookshelf = false;
              });
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Removed from bookshelf'), duration: Duration(seconds: 2)),
              );
            }
          } else {
            await bookshelfNotifier.addBook(
                  id: bookId,
                  title: bookTitle,
                  author: bookAuthor,
                  coverUrl: bookCoverUrl,
                  category: bookCategory,
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
