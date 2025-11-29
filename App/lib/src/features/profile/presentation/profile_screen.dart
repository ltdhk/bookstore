import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_store/src/features/auth/providers/auth_provider.dart';
import 'package:book_store/l10n/app_localizations.dart';
import 'package:book_store/src/features/subscription/presentation/subscription_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showSubscriptionDialog(BuildContext context, WidgetRef ref) {
    // Check if user is logged in
    final authState = ref.read(authProvider);

    authState.whenOrNull(
      data: (user) {
        if (user == null) {
          // User not logged in, show login dialog
          _showLoginDialog(context);
        } else {
          // User logged in, show subscription dialog
          showDialog(
            context: context,
            builder: (context) => const SubscriptionDialog(
              sourceEntry: 'profile',
            ),
          );
        }
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 20),
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF3D7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            Text(
              'Novel Master',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            // Login with Apple button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Apple login
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log in via apple',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Login with Google button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Google login
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log in via google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Login with Email button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log in via Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Agreement text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
                children: const [
                  TextSpan(text: 'When you log in, we will assume that you have read and agreed to the\n'),
                  TextSpan(
                    text: 'User Agreement',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ' & '),
                  TextSpan(
                    text: 'Privacy Agreement',
                    style: TextStyle(
                      color: Color(0xFFFF6B9D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
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
                      : 'Master-2072835';
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
                                  : 'ID: 2072835  Hi novel!',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.grey[400] : Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLoggedIn)
                        ElevatedButton(
                          onPressed: () => _showLoginDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : Colors.black,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Log In'),
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
                          child: const Text('Log Out'),
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
                            'Loading...',
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
                            'Master-2072835',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: 2072835  Hi novel!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? Colors.grey[400] : Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showLoginDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Log In'),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SVIP MEMBERSHIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Read all novels on the site without restrictions',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showSubscriptionDialog(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD54F), // Amber
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Subscribe now'),
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
                    'Reading history',
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
                    'Transaction Record',
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
                    'Setting',
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
