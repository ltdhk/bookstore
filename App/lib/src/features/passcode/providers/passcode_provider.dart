import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/passcode/data/models/passcode_context.dart';
import 'package:novelpop/src/features/passcode/data/passcode_api_service.dart';

part 'passcode_provider.g.dart';

/// 口令上下文有效期（小时）
/// 超过此时间的口令上下文将不会被用于订阅关联
const int _passcodeContextValidityHours = 24;

/// Global passcode context provider.
/// Stores the currently active passcode context for tracking.
/// This is kept alive throughout the app session (memory only, not persisted).
@Riverpod(keepAlive: true)
class ActivePasscodeContext extends _$ActivePasscodeContext {
  @override
  PasscodeContext? build() {
    return null;
  }

  /// Set active passcode context
  void setContext(PasscodeContext context) {
    state = context;
    debugPrint('PasscodeContext set: $context');
  }

  /// Clear active passcode context
  void clearContext() {
    state = null;
    debugPrint('PasscodeContext cleared');
  }

  /// Check if current book matches the active passcode
  bool isPasscodeActiveForBook(int bookId) {
    return state?.bookId == bookId;
  }

  /// Get passcode context for a specific book
  PasscodeContext? getContextForBook(int bookId) {
    if (state?.bookId == bookId) {
      return state;
    }
    return null;
  }

  /// 更新口令上下文的最后访问时间
  /// 当用户通过口令打开书籍阅读器时调用
  void updateLastAccessed(int bookId) {
    if (state != null && state!.bookId == bookId) {
      state = state!.copyWithLastAccessed();
      debugPrint('PasscodeContext lastAccessedAt updated for book $bookId');
    }
  }

  /// 获取最近访问的口令上下文（用于非书籍页面的订阅）
  /// 仅当口令在有效期内时返回
  /// [validityHours] 口令有效期（小时），默认24小时
  PasscodeContext? getRecentPasscodeContext({
    int validityHours = _passcodeContextValidityHours,
  }) {
    if (state == null) return null;

    final now = DateTime.now();
    final lastAccessed = state!.lastAccessedAt;
    final hoursSinceAccess = now.difference(lastAccessed).inHours;

    if (hoursSinceAccess <= validityHours) {
      debugPrint(
        'Using recent passcode context (accessed ${hoursSinceAccess}h ago): ${state!.passcodeId}',
      );
      return state;
    }

    debugPrint(
      'Passcode context expired (accessed ${hoursSinceAccess}h ago, limit: ${validityHours}h)',
    );
    return null;
  }
}

/// Provider to track passcode usage when entering reader
@riverpod
class PasscodeUsageTracker extends _$PasscodeUsageTracker {
  @override
  bool build() => false;

  /// Track passcode usage when opening a book
  Future<void> trackBookOpen(int bookId, {int? userId}) async {
    final context = ref.read(activePasscodeContextProvider);
    if (context != null && context.bookId == bookId) {
      final apiService = ref.read(passcodeApiServiceProvider);
      try {
        await apiService.usePasscode(
          passcode: context.passcode,
          bookId: bookId,
          userId: userId,
        );
        debugPrint('Passcode usage tracked for book $bookId');
      } catch (e) {
        // Log error but don't block user
        debugPrint('Failed to track passcode usage: $e');
      }
    }
  }
}
