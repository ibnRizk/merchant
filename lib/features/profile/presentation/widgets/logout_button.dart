import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/confirm_dialog.dart';

/// Full-width destructive outline button that ends the session.
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.error,
                ),
              )
            : const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          Strings.logout,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.error,
          disabledForegroundColor: colors.error.withValues(alpha: 0.6),
          side: BorderSide(color: colors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Resolves to `true` only when the merchant confirms.
Future<bool> showLogoutConfirmation(BuildContext context) => showConfirmDialog(
  context,
  icon: Icons.logout_rounded,
  title: Strings.logoutConfirmTitle,
  message: Strings.logoutConfirmMessage,
  confirmLabel: Strings.logout,
);
