/// Utility class to detect if a string is a passcode.
/// Passcode format: starts with "KL" followed by 4 digits (0000-9999).
class PasscodeDetector {
  /// Passcode pattern: starts with "KL" followed by 4 digits
  static final RegExp _passcodePattern =
      RegExp(r'^KL[0-9]{4}$', caseSensitive: false);

  /// Check if the input looks like a passcode
  static bool isPasscode(String input) {
    if (input.isEmpty) return false;
    final trimmed = input.trim().toUpperCase();
    return _passcodePattern.hasMatch(trimmed);
  }

  /// Normalize passcode to uppercase
  static String normalize(String passcode) {
    return passcode.trim().toUpperCase();
  }
}
