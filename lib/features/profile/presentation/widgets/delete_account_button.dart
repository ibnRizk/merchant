import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Low-emphasis destructive link under the logout button, so it can't be
/// mistaken for it.
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Center(
      child: TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.error,
                ),
              )
            : const Icon(Icons.delete_outline_rounded, size: 18),
        label: Text(
          Strings.deleteAccount,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: colors.error,
          disabledForegroundColor: colors.error.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
