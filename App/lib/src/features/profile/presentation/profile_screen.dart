import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:novelpop/src/features/auth/providers/auth_provider.dart';
import 'package:novelpop/l10n/app_localizations.dart';
import 'package:novelpop/src/common_widgets/login_bottom_sheet.dart';
import 'package:novelpop/src/features/subscription/utils/subscription_flow_helper.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // User Info Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: authState.when(
                data: (user) {
                  final isLoggedIn = user != null;
                  final displayName = isLoggedIn
                      ? (user.nickname ?? user.username)
                      : 'User-207283';
                  final username = isLoggedIn
                      ? user.username
                      : '';
                  final isSvip = isLoggedIn && (user.isSvip ?? false);

                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  displayName,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (isLoggedIn) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSvip
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFFD700),
                                                Color(0xFFFFA500),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSvip ? null : Colors.grey[600],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSvip ? Icons.diamond : Icons.person,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isSvip ? l10n.svipMember : l10n.regularMember,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoggedIn
                                  ? 'ID: $username'
                                  : 'ID: 207283  Hi novel!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.grey[400] : Colors.grey,
                                  ),
                            ),
                            if (isLoggedIn && isSvip && user.subscriptionEndDate != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${l10n.expiresOn}: ${_formatDate(user.subscriptionEndDate!)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isLoggedIn)
                        ElevatedButton(
                          onPressed: () => LoginBottomSheet.show(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(l10n.login),
                        )
                      else
                        ElevatedButton(
                          onPressed: () async {
                            await ref.read(authProvider.notifier).logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(l10n.logout),
                        ),
                    ],
                  );
                },
                loading: () => Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.loading,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                error: (error, stack) => Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User-207283',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: 207283  Hi novel!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.grey[400] : Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => LoginBottomSheet.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(l10n.login),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // SVIP Membership
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E), // Dark blue
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.svipMembership,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.readAllNovels,
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => SubscriptionFlowHelper.showSubscriptionFlow(
                      context: context,
                      ref: ref,
                      sourceBookId: null, // Profile 页面无书籍关联
                      sourceEntry: 'profile',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F), // Amber
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(l10n.subscribeNow),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Menu Options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.history,
                    l10n.readingHistory,
                    isDark,
                    onTap: () => context.push('/reading-history'),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  _buildMenuItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    l10n.transactionRecord,
                    isDark,
                    onTap: () => context.push('/transaction-record'),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  _buildMenuItem(
                    context,
                    Icons.settings_outlined,
                    l10n.setting,
                    isDark,
                    onTap: () => context.go('/profile/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? Colors.white : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
