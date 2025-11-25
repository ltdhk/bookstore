/// Utility class to detect if a string is a passcode.
/// Passcode format: starts with "KL" followed by 8 alphanumeric characters.
class PasscodeDetector {
  /// Passcode pattern: starts with "KL" followed by 8 alphanumeric characters
  static final RegExp _passcodePattern =
      RegExp(r'^KL[A-Z0-9]{8}$', caseSensitive: false);

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
