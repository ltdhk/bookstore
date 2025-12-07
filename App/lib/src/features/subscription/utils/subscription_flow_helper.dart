import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novelpop/src/common_widgets/login_bottom_sheet.dart';
import 'package:novelpop/src/features/auth/providers/auth_provider.dart';
import 'package:novelpop/src/features/subscription/presentation/subscription_dialog.dart';

/// 订阅流程辅助类
///
/// 封装了登录检查和订阅对话框显示的逻辑
/// 支持 Passcode 关联（通过 sourceBookId 参数）
class SubscriptionFlowHelper {
  /// 显示订阅流程（自动处理登录检查）
  ///
  /// [context] - BuildContext
  /// [ref] - WidgetRef，用于读取 provider
  /// [sourceBookId] - 来源书籍ID，用于 Passcode 关联（Reader 传入，Profile 传 null）
  /// [sourceEntry] - 入口标识 ('reader' | 'profile' | 'home' 等)
  /// [onSuccess] - 订阅成功回调
  ///
  /// 工作流程：
  /// 1. 检查用户是否已登录
  /// 2. 未登录 → 显示 LoginBottomSheet
  /// 3. 已登录 → 显示 SubscriptionDialog
  /// 4. 订阅成功后执行 onSuccess 回调
  ///
  /// Passcode 关联说明：
  /// - sourceBookId 是关键参数，SubscriptionDialog 内部会：
  ///   1. 检查 activePasscodeContextProvider 中是否有匹配的 bookId
  ///   2. 如果匹配，提取 passcodeId 和 distributorId
  ///   3. 传递给 IAP Service 和后端 API
  static void showSubscriptionFlow({
    required BuildContext context,
    required WidgetRef ref,
    int? sourceBookId,
    required String sourceEntry,
    VoidCallback? onSuccess,
  }) {
    final authState = ref.read(authProvider);

    authState.whenOrNull(
      data: (user) {
        if (user == null) {
          // 未登录 → 显示登录，登录成功后再显示订阅
          LoginBottomSheet.show(
            context,
            onLoginSuccess: () {
              // 登录成功后，延迟一下再显示订阅对话框
              // 确保 authProvider 状态已更新
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  _showSubscriptionDialog(
                    context,
                    sourceBookId,
                    sourceEntry,
                    onSuccess,
                  );
                }
              });
            },
          );
        } else {
          // 已登录 → 直接显示订阅
          _showSubscriptionDialog(
            context,
            sourceBookId,
            sourceEntry,
            onSuccess,
          );
        }
      },
    );
  }

  /// 显示订阅对话框
  static void _showSubscriptionDialog(
    BuildContext context,
    int? sourceBookId,
    String sourceEntry,
    VoidCallback? onSuccess,
  ) {
    showDialog(
      context: context,
      builder: (context) => SubscriptionDialog(
        sourceBookId: sourceBookId, // Passcode 关联的关键参数
        sourceEntry: sourceEntry,
      ),
    ).then((result) {
      if (result == true) {
        onSuccess?.call();
      }
    });
  }
}
