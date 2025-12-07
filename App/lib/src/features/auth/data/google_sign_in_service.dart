import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInResult {
  final String idToken;
  final String? serverAuthCode;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  GoogleSignInResult({
    required this.idToken,
    this.serverAuthCode,
    this.email,
    this.displayName,
    this.photoUrl,
  });
}

class GoogleSignInService {
  late final GoogleSignIn _googleSignIn;

  GoogleSignInService({
    required String webClientId,
    String? iosClientId,
  }) {
    _googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
      scopes: ['email', 'profile'],
    );
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInResult> signIn() async {
    try {
      debugPrint('[GoogleSignIn] Starting sign in...');
      debugPrint('[GoogleSignIn] serverClientId: ${_googleSignIn.serverClientId}');

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      debugPrint('[GoogleSignIn] signIn() returned, account: ${account?.email}');

      if (account == null) {
        debugPrint('[GoogleSignIn] ERROR: account is null (user cancelled)');
        throw Exception('Google Sign In was cancelled');
      }

      debugPrint('[GoogleSignIn] Account email: ${account.email}');
      debugPrint('[GoogleSignIn] Account displayName: ${account.displayName}');
      debugPrint('[GoogleSignIn] Getting authentication...');

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      debugPrint('[GoogleSignIn] idToken: ${idToken != null ? "obtained (${idToken.length} chars)" : "NULL"}');
      debugPrint('[GoogleSignIn] accessToken: ${auth.accessToken != null ? "obtained" : "NULL"}');

      if (idToken == null) {
        debugPrint('[GoogleSignIn] ERROR: idToken is null');
        throw Exception('Failed to obtain Google ID token');
      }

      debugPrint('[GoogleSignIn] Sign in successful, returning result');
      return GoogleSignInResult(
        idToken: idToken,
        serverAuthCode: auth.serverAuthCode,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (e, stackTrace) {
      debugPrint('[GoogleSignIn] ERROR: $e');
      debugPrint('[GoogleSignIn] StackTrace: $stackTrace');
      throw Exception('Google Sign In failed: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
