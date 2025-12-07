import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:novelpop/src/config/google_config.dart';
import 'package:novelpop/src/features/auth/providers/auth_provider.dart';
import 'package:novelpop/l10n/app_localizations.dart';

/// 通用登录底部弹窗组件
///
/// 包含 Apple、Google、Email 三种登录方式
/// 可在任何需要登录的地方使用
class LoginBottomSheet extends ConsumerStatefulWidget {
  /// 登录成功后的回调
  final VoidCallback? onLoginSuccess;

  const LoginBottomSheet({super.key, this.onLoginSuccess});

  /// 显示登录底部弹窗
  static void show(BuildContext context, {VoidCallback? onLoginSuccess}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LoginBottomSheet(onLoginSuccess: onLoginSuccess),
    );
  }

  @override
  ConsumerState<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<LoginBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // App name
          Text(
            l10n.novelMaster,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 40),
          // Login with Apple button
          _AppleLoginButton(
            l10n: l10n,
            onLoginSuccess: widget.onLoginSuccess,
          ),
          const SizedBox(height: 16),
          // Login with Google button
          _GoogleLoginButton(
            l10n: l10n,
            onLoginSuccess: widget.onLoginSuccess,
          ),
          const SizedBox(height: 16),
          // Login with Email button
          _EmailLoginButton(
            l10n: l10n,
            onLoginSuccess: widget.onLoginSuccess,
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
              children: [
                TextSpan(text: l10n.whenYouLogin),
                TextSpan(
                  text: l10n.userAgreement,
                  style: const TextStyle(
                    color: Color(0xFFFF6B9D),
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: l10n.privacyAgreement,
                  style: const TextStyle(
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
    );
  }
}

/// Apple 登录按钮（带 loading 状态）
class _AppleLoginButton extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback? onLoginSuccess;

  const _AppleLoginButton({required this.l10n, this.onLoginSuccess});

  @override
  ConsumerState<_AppleLoginButton> createState() => _AppleLoginButtonState();
}

class _AppleLoginButtonState extends ConsumerState<_AppleLoginButton> {
  bool _isLoading = false;

  Future<void> _handleAppleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Close the dialog first
      if (mounted) {
        Navigator.pop(context);
      }

      if (!Platform.isIOS && !Platform.isMacOS) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple login is only available on iOS/macOS devices'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await ref.read(authProvider.notifier).loginWithApple();

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.loginFailed(authState.error.toString())),
            backgroundColor: Colors.red,
          ),
        );
      } else if (authState.hasValue && authState.value != null) {
        // 登录成功，执行回调
        widget.onLoginSuccess?.call();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAppleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFFF6B9D).withValues(alpha: 0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.l10n.loginViaApple,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Google 登录按钮（带 loading 状态）
class _GoogleLoginButton extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback? onLoginSuccess;

  const _GoogleLoginButton({required this.l10n, this.onLoginSuccess});

  @override
  ConsumerState<_GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends ConsumerState<_GoogleLoginButton> {
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Close the dialog first
      if (mounted) {
        Navigator.pop(context);
      }

      await ref.read(authProvider.notifier).loginWithGoogle(
            webClientId: GoogleConfig.webClientId,
            iosClientId: Platform.isIOS ? GoogleConfig.iosClientId : null,
          );

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l10n.loginFailed(authState.error.toString())),
            backgroundColor: Colors.red,
          ),
        );
      } else if (authState.hasValue && authState.value != null) {
        // 登录成功，执行回调
        widget.onLoginSuccess?.call();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          disabledBackgroundColor: const Color(0xFFFF6B9D).withValues(alpha: 0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.l10n.loginViaGoogle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Email 登录按钮
class _EmailLoginButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback? onLoginSuccess;

  const _EmailLoginButton({required this.l10n, this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          context.push('/login');
          // Email 登录需要在登录页面处理成功回调
          // onLoginSuccess 会在用户从登录页面返回后由调用方处理
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
        child: Text(
          l10n.loginViaEmail,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
