import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Lightweight on-brand snackbar for actions that don't navigate anywhere
/// (save confirmations, placeholders for not-yet-built flows, ...).
void showBrandSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final AppColors colors = context.colors;
  final ColorScheme scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isError ? scheme.onError : scheme.onSecondary,
          ),
        ),
        backgroundColor: isError ? colors.error : colors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
}
