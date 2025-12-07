import 'package:flutter/foundation.dart';
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

  /// Refresh user profile from server
  /// Call this after subscription purchase to update user's SVIP status
  Future<void> refreshProfile() async {
    // Only refresh if user is logged in
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final authService = ref.read(authApiServiceProvider);
      final updatedUser = await authService.getProfile();

      // Update state with new user data, keeping the existing token
      state = AsyncValue.data(updatedUser.copyWith(token: currentUser.token));
      debugPrint('User profile refreshed successfully');
    } catch (e) {
      // Silently fail - don't disrupt user experience
      // The profile will be refreshed on next app launch
      debugPrint('Failed to refresh profile: $e');
    }
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
    debugPrint('[AuthProvider] loginWithGoogle started');
    debugPrint('[AuthProvider] webClientId: $webClientId');
    debugPrint('[AuthProvider] iosClientId: $iosClientId');

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Initialize Google service
      debugPrint('[AuthProvider] Creating GoogleSignInService...');
      final googleService = GoogleSignInService(
        webClientId: webClientId,
        iosClientId: iosClientId,
      );

      // Perform Google Sign In
      debugPrint('[AuthProvider] Calling googleService.signIn()...');
      final googleResult = await googleService.signIn();
      debugPrint('[AuthProvider] Google sign in completed, email: ${googleResult.email}');

      // Send to backend
      debugPrint('[AuthProvider] Sending to backend...');
      final authService = ref.read(authApiServiceProvider);
      final request = GoogleSignInRequest(
        idToken: googleResult.idToken,
        serverAuthCode: googleResult.serverAuthCode,
        email: googleResult.email,
        displayName: googleResult.displayName,
        photoUrl: googleResult.photoUrl,
      );

      debugPrint('[AuthProvider] Calling authService.loginWithGoogle...');
      final user = await authService.loginWithGoogle(request);
      debugPrint('[AuthProvider] Backend returned user: ${user.username}, id: ${user.id}');

      // Save user data and token
      debugPrint('[AuthProvider] Saving user data to SharedPreferences...');
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

      debugPrint('[AuthProvider] Login complete, returning user');
      return user;
    });

    debugPrint('[AuthProvider] Final state: hasValue=${state.hasValue}, hasError=${state.hasError}');
    if (state.hasError) {
      debugPrint('[AuthProvider] Error: ${state.error}');
    }
    if (state.hasValue) {
      debugPrint('[AuthProvider] User value: ${state.value?.username}');
    }
  }
}
