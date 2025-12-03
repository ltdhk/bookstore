import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/services/networking/dio_provider.dart';
import 'package:novelpop/src/features/auth/data/models/apple_sign_in_request.dart';
import 'package:novelpop/src/features/auth/data/models/google_sign_in_request.dart';
import 'package:novelpop/src/features/auth/data/models/login_request.dart';
import 'package:novelpop/src/features/auth/data/models/register_request.dart';
import 'package:novelpop/src/features/auth/data/models/user_vo.dart';
import 'package:novelpop/src/features/auth/data/models/api_result.dart';

part 'auth_api_service.g.dart';

@riverpod
AuthApiService authApiService(Ref ref) {
  return AuthApiService(ref.watch(dioProvider));
}

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  Future<UserVO> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );

      final result = ApiResult<UserVO>.fromJson(
        response.data,
        (json) => UserVO.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final result = ApiResult<UserVO>.fromJson(e.response!.data, null);
        throw Exception(result.message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<UserVO> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );

      final result = ApiResult<UserVO>.fromJson(
        response.data,
        (json) => UserVO.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final result = ApiResult<UserVO>.fromJson(e.response!.data, null);
        throw Exception(result.message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<UserVO> loginWithApple(AppleSignInRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/apple',
        data: request.toJson(),
      );

      final result = ApiResult<UserVO>.fromJson(
        response.data,
        (json) => UserVO.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final result = ApiResult<UserVO>.fromJson(e.response!.data, null);
        throw Exception(result.message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<UserVO> loginWithGoogle(GoogleSignInRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/google',
        data: request.toJson(),
      );

      final result = ApiResult<UserVO>.fromJson(
        response.data,
        (json) => UserVO.fromJson(json as Map<String, dynamic>),
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      } else {
        throw Exception(result.message);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final result = ApiResult<UserVO>.fromJson(e.response!.data, null);
        throw Exception(result.message);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
