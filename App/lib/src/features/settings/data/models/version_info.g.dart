// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionInfo _$VersionInfoFromJson(Map<String, dynamic> json) => VersionInfo(
  hasUpdate: json['hasUpdate'] as bool,
  forceUpdate: json['forceUpdate'] as bool,
  latestVersion: json['latestVersion'] as String?,
  latestVersionCode: (json['latestVersionCode'] as num?)?.toInt(),
  updateUrl: json['updateUrl'] as String?,
  releaseNotes: json['releaseNotes'] as String?,
);

Map<String, dynamic> _$VersionInfoToJson(VersionInfo instance) =>
    <String, dynamic>{
      'hasUpdate': instance.hasUpdate,
      'forceUpdate': instance.forceUpdate,
      'latestVersion': instance.latestVersion,
      'latestVersionCode': instance.latestVersionCode,
      'updateUrl': instance.updateUrl,
      'releaseNotes': instance.releaseNotes,
    };
