class AppVersionInfo {
  final String platform;
  final String latestVersion;
  final String minimumVersion;
  final String currentVersion;
  final bool isUpdateRequired;
  final bool forceUpdate;
  final String? updateUrl;
  final String? releaseNotes;
  final String message;

  AppVersionInfo({
    required this.platform,
    required this.latestVersion,
    required this.minimumVersion,
    required this.currentVersion,
    required this.isUpdateRequired,
    this.forceUpdate = true,
    this.updateUrl,
    this.releaseNotes,
    required this.message,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      platform: json['platform']?.toString() ?? 'Android',
      latestVersion: json['latestVersion']?.toString() ?? '1.0.3',
      minimumVersion: json['minimumVersion']?.toString() ?? '1.0.3',
      currentVersion: json['currentVersion']?.toString() ?? '',
      isUpdateRequired: json['isUpdateRequired'] as bool? ?? false,
      forceUpdate: json['forceUpdate'] as bool? ?? true,
      updateUrl: json['updateUrl']?.toString(),
      releaseNotes: json['releaseNotes']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }
}
