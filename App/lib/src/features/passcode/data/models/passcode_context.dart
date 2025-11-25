/// Passcode context model for tracking passcode usage throughout the app session.
/// This context is stored in memory only and cleared when the app closes.
class PasscodeContext {
  final int passcodeId;
  final int distributorId;
  final int bookId;
  final String passcode;
  final DateTime createdAt;

  PasscodeContext({
    required this.passcodeId,
    required this.distributorId,
    required this.bookId,
    required this.passcode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String toString() {
    return 'PasscodeContext(passcodeId: $passcodeId, distributorId: $distributorId, bookId: $bookId, passcode: $passcode)';
  }
}
