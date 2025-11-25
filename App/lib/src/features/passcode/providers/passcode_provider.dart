import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:book_store/src/features/passcode/data/models/passcode_context.dart';
import 'package:book_store/src/features/passcode/data/passcode_api_service.dart';

part 'passcode_provider.g.dart';

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
