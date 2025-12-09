import 'dart:io';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/services/networking/dio_provider.dart';
import 'package:novelpop/src/features/settings/data/models/version_info.dart';

part 'version_api_service.g.dart';

@riverpod
VersionApiService versionApiService(Ref ref) {
  return VersionApiService(ref.watch(dioProvider));
}

class VersionApiService {
  final Dio _dio;

  VersionApiService(this._dio);

  /// Check for version update
  /// [versionCode] - the current app version code (e.g., 10005 for version 1.0.0+5)
  Future<VersionInfo> checkVersion(int versionCode) async {
    final platform = Platform.isIOS ? 'ios' : 'android';

    final response = await _dio.get(
      '/api/v1/version/check',
      queryParameters: {
        'platform': platform,
        'versionCode': versionCode,
      },
    );

    return VersionInfo.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
