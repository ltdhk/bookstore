/// Passcode context model for tracking passcode usage throughout the app session.
/// This context is stored in memory only and cleared when the app closes.
class PasscodeContext {
  final int passcodeId;
  final int distributorId;
  final int bookId;
  final String passcode;
  final DateTime createdAt;

  /// 最后访问时间，用于跟踪用户最近通过口令访问的书籍
  /// 当用户打开阅读器时更新此时间戳
  final DateTime lastAccessedAt;

  PasscodeContext({
    required this.passcodeId,
    required this.distributorId,
    required this.bookId,
    required this.passcode,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();

  /// 创建一个更新了 lastAccessedAt 的新实例
  PasscodeContext copyWithLastAccessed() {
    return PasscodeContext(
      passcodeId: passcodeId,
      distributorId: distributorId,
      bookId: bookId,
      passcode: passcode,
      createdAt: createdAt,
      lastAccessedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PasscodeContext(passcodeId: $passcodeId, distributorId: $distributorId, bookId: $bookId, passcode: $passcode, lastAccessedAt: $lastAccessedAt)';
  }
}
