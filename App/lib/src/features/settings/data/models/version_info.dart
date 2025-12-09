import 'package:json_annotation/json_annotation.dart';

part 'version_info.g.dart';

@JsonSerializable()
class VersionInfo {
  final bool hasUpdate;
  final bool forceUpdate;
  final String? latestVersion;
  final int? latestVersionCode;
  final String? updateUrl;
  final String? releaseNotes;

  VersionInfo({
    required this.hasUpdate,
    required this.forceUpdate,
    this.latestVersion,
    this.latestVersionCode,
    this.updateUrl,
    this.releaseNotes,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) =>
      _$VersionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VersionInfoToJson(this);
}
