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
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        throw Exception('Google Sign In was cancelled');
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to obtain Google ID token');
      }

      return GoogleSignInResult(
        idToken: idToken,
        serverAuthCode: auth.serverAuthCode,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
