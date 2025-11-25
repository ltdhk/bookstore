import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_store/l10n/app_localizations.dart';
import 'package:book_store/src/features/settings/data/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _autoUnlock = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16),
        children: [
          _buildListTile(
            title: l10n.darkMode,
            trailing: Consumer(
              builder: (context, ref, child) {
                final themeMode =
                    ref.watch(themeControllerProvider).value ??
                    ThemeMode.system;
                String themeText;
                switch (themeMode) {
                  case ThemeMode.dark:
                    themeText = l10n.alwaysDark;
                    break;
                  case ThemeMode.light:
                    themeText = l10n.alwaysLight;
                    break;
                  case ThemeMode.system:
                    themeText = l10n.followSystem;
                    break;
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      themeText,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                );
              },
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: const Color(0xFF1E1E1E),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => Consumer(
                  builder: (context, ref, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildThemeOption(
                          context,
                          ref,
                          l10n.followSystem,
                          ThemeMode.system,
                        ),
                        _buildThemeOption(
                          context,
                          ref,
                          l10n.alwaysDark,
                          ThemeMode.dark,
                        ),
                        _buildThemeOption(
                          context,
                          ref,
                          l10n.alwaysLight,
                          ThemeMode.light,
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          _buildDivider(),
          SwitchListTile(
            title: Text(
              l10n.autoUnlockChapter,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            value: _autoUnlock,
            onChanged: (value) {
              setState(() {
                _autoUnlock = value;
              });
            },
            activeColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            activeTrackColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          _buildDivider(),
          _buildListTile(
            title: l10n.language,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'English',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: l10n.versionUpdate,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Version v2.27',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: l10n.about,
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildListTile(
            title: l10n.rate,
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeMode mode,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
      onTap: () {
        ref.read(themeControllerProvider.notifier).updateThemeMode(mode);
        context.pop();
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2C)
          : const Color(0xFFEEEEEE),
    );
  }
}
