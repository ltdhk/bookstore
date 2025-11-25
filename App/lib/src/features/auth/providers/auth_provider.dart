import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_store/src/features/auth/data/auth_api_service.dart';
import 'package:book_store/src/features/auth/data/models/login_request.dart';
import 'package:book_store/src/features/auth/data/models/register_request.dart';
import 'package:book_store/src/features/auth/data/models/user_vo.dart';

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
}
