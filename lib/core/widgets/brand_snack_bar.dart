import 'package:flutter/material.dart';

import '../utils/values/brand_colors.dart';

/// Lightweight on-brand snackbar for actions that don't navigate anywhere
/// (save confirmations, placeholders for not-yet-built flows, ...).
void showBrandSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? BrandColors.cancelledText : BrandColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
}
