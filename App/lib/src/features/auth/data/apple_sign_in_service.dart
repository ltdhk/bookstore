import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInResult {
  final String identityToken;
  final String? authorizationCode;
  final String? email;
  final String? fullName;
  final String nonce;

  AppleSignInResult({
    required this.identityToken,
    this.authorizationCode,
    this.email,
    this.fullName,
    required this.nonce,
  });
}

class AppleSignInService {
  /// Check if Apple Sign In is available on this device
  Future<bool> isAvailable() async {
    return await SignInWithApple.isAvailable();
  }

  /// Generate a random nonce for security
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Hash nonce using SHA256 for Apple
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Perform Apple Sign In
  Future<AppleSignInResult> signIn() async {
    // Generate nonce for replay attack prevention
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Get identity token
      final identityToken = credential.identityToken;
      if (identityToken == null) {
        throw Exception('Apple Sign In failed: No identity token received');
      }

      // Combine full name if provided
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [credential.givenName, credential.familyName]
            .where((n) => n != null && n.isNotEmpty)
            .join(' ');
        if (fullName.isEmpty) fullName = null;
      }

      return AppleSignInResult(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        fullName: fullName,
        nonce: rawNonce, // Send raw nonce to backend for verification
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('Apple Sign In was cancelled');
        case AuthorizationErrorCode.failed:
          throw Exception('Apple Sign In failed: ${e.message}');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('Apple Sign In received invalid response');
        case AuthorizationErrorCode.notHandled:
          throw Exception('Apple Sign In not handled');
        case AuthorizationErrorCode.notInteractive:
          throw Exception('Apple Sign In requires interactive session');
        default:
          throw Exception('Apple Sign In error: ${e.message}');
      }
    }
  }
}
