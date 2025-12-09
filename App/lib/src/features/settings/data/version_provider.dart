import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:novelpop/src/features/settings/data/version_api_service.dart';
import 'package:novelpop/src/features/settings/data/models/version_info.dart';

part 'version_provider.g.dart';

/// Provider for current app version info
@riverpod
Future<PackageInfo> packageInfo(Ref ref) async {
  return await PackageInfo.fromPlatform();
}

/// Provider for checking version update
@riverpod
class VersionCheck extends _$VersionCheck {
  @override
  Future<VersionInfo?> build() async {
    return null;
  }

  /// Check for updates
  Future<VersionInfo?> checkForUpdate() async {
    try {
      final packageInfo = await ref.read(packageInfoProvider.future);
      final versionApiService = ref.read(versionApiServiceProvider);

      // Get build number as version code
      final versionCode = int.tryParse(packageInfo.buildNumber) ?? 1;

      final versionInfo = await versionApiService.checkVersion(versionCode);
      state = AsyncData(versionInfo);
      return versionInfo;
    } catch (e) {
      debugPrint('Error checking version: $e');
      state = const AsyncData(null);
      return null;
    }
  }
}
