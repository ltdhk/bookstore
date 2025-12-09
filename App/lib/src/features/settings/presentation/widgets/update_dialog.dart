import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novelpop/src/features/settings/data/models/version_info.dart';

class UpdateDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  final VoidCallback? onLater;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    this.onLater,
  });

  /// Show update dialog
  static Future<void> show(
    BuildContext context,
    VersionInfo versionInfo,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: !versionInfo.forceUpdate,
      builder: (context) => UpdateDialog(
        versionInfo: versionInfo,
        onLater: versionInfo.forceUpdate
            ? null
            : () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _launchStore() async {
    if (versionInfo.updateUrl != null) {
      final uri = Uri.parse(versionInfo.updateUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !versionInfo.forceUpdate,
      child: AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          versionInfo.forceUpdate ? 'Update Required' : 'New Version Available',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v${versionInfo.latestVersion}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (versionInfo.forceUpdate) ...[
              Text(
                'Your current version is no longer supported. Please update to continue using the app.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            if (versionInfo.releaseNotes != null &&
                versionInfo.releaseNotes!.isNotEmpty) ...[
              Text(
                "What's New:",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    versionInfo.releaseNotes!,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (!versionInfo.forceUpdate && onLater != null)
            TextButton(
              onPressed: onLater,
              child: Text(
                'Later',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: _launchStore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Update Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
