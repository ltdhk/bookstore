/// Utility class to detect if a string is a passcode.
/// Passcode format: 4-5 digit number (e.g., 1234 or 12345).
class PasscodeDetector {
  /// Passcode pattern: 4 or 5 digits only
  static final RegExp _passcodePattern = RegExp(r'^[0-9]{4,5}$');

  /// Check if the input looks like a passcode (4-5 digit number)
  static bool isPasscode(String input) {
    if (input.isEmpty) return false;
    final trimmed = input.trim();
    return _passcodePattern.hasMatch(trimmed);
  }

  /// Normalize passcode (trim whitespace)
  static String normalize(String passcode) {
    return passcode.trim();
  }
}
