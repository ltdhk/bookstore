import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novelpop/l10n/app_localizations.dart';
import 'package:novelpop/src/features/settings/data/version_provider.dart';
import 'package:novelpop/src/features/settings/presentation/widgets/update_dialog.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  bool _hasCheckedVersion = false;

  @override
  void initState() {
    super.initState();
    // Check version after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersion();
    });
  }

  Future<void> _checkVersion() async {
    if (_hasCheckedVersion) return;
    _hasCheckedVersion = true;

    final versionInfo =
        await ref.read(versionCheckProvider.notifier).checkForUpdate();

    if (versionInfo != null && versionInfo.hasUpdate && mounted) {
      UpdateDialog.show(context, versionInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, thickness: 0.5),
          NavigationBar(
            height: 60,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: (int index) => _onTap(context, index),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book),
                label: l10n.bookshelf,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.profile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
