import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novelpop/src/features/auth/data/apple_sign_in_service.dart';
import 'package:novelpop/src/features/auth/data/google_sign_in_service.dart';
import 'package:novelpop/src/features/auth/data/auth_api_service.dart';
import 'package:novelpop/src/features/auth/data/models/apple_sign_in_request.dart';
import 'package:novelpop/src/features/auth/data/models/google_sign_in_request.dart';
import 'package:novelpop/src/features/auth/data/models/login_request.dart';
import 'package:novelpop/src/features/auth/data/models/register_request.dart';
import 'package:novelpop/src/features/auth/data/models/user_vo.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserVO?> build() async {
    return await _loadUser();
  }

  Future<UserVO?> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (token != null && userJson != null) {
        // In a real app, you might want to verify the token is still valid
        // For now, we'll just return null and require re-login
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final authService = ref.read(authApiServiceProvider);
      final request = LoginRequest(username: username, password: password);
      final user = await authService.login(request);

      // Save user data and token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('user_id', user.id.toString());
      await prefs.setString('username', user.username);
      if (user.nickname != null) {
        await prefs.setString('nickname', user.nickname!);
      }
      if (user.avatar != null) {
        await prefs.setString('avatar', user.avatar!);
      }

      return user;
    });
  }

  Future<void> register(String username, String password, String? nickname) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final authService = ref.read(authApiServiceProvider);
      final request = RegisterRequest(
        username: username,
        password: password,
        nickname: nickname,
      );
      final user = await authService.register(request);

      // Save user data and token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('user_id', user.id.toString());
      await prefs.setString('username', user.username);
      if (user.nickname != null) {
        await prefs.setString('nickname', user.nickname!);
      }
      if (user.avatar != null) {
        await prefs.setString('avatar', user.avatar!);
      }

      return user;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('nickname');
    await prefs.remove('avatar');

    state = const AsyncValue.data(null);
  }

  Future<void> loginWithApple() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final appleService = AppleSignInService();

      // Check availability
      if (!await appleService.isAvailable()) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Perform Apple Sign In
      final appleResult = await appleService.signIn();

      // Send to backend
      final authService = ref.read(authApiServiceProvider);
      final request = AppleSignInRequest(
        identityToken: appleResult.identityToken,
        authorizationCode: appleResult.authorizationCode,
        email: appleResult.email,
        fullName: appleResult.fullName,
        nonce: appleResult.nonce,
      );
      final user = await authService.loginWithApple(request);

      // Save user data and token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('user_id', user.id.toString());
      await prefs.setString('username', user.username);
      if (user.nickname != null) {
        await prefs.setString('nickname', user.nickname!);
      }
      if (user.avatar != null) {
        await prefs.setString('avatar', user.avatar!);
      }

      return user;
    });
  }

  Future<void> loginWithGoogle({
    required String webClientId,
    String? iosClientId,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Initialize Google service
      final googleService = GoogleSignInService(
        webClientId: webClientId,
        iosClientId: iosClientId,
      );

      // Perform Google Sign In
      final googleResult = await googleService.signIn();

      // Send to backend
      final authService = ref.read(authApiServiceProvider);
      final request = GoogleSignInRequest(
        idToken: googleResult.idToken,
        serverAuthCode: googleResult.serverAuthCode,
        email: googleResult.email,
        displayName: googleResult.displayName,
        photoUrl: googleResult.photoUrl,
      );
      final user = await authService.loginWithGoogle(request);

      // Save user data and token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('user_id', user.id.toString());
      await prefs.setString('username', user.username);
      if (user.nickname != null) {
        await prefs.setString('nickname', user.nickname!);
      }
      if (user.avatar != null) {
        await prefs.setString('avatar', user.avatar!);
      }

      return user;
    });
  }
}
