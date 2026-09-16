import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Circular back button for standalone-pushed screens that don't use the
/// app's default [AppBar]. The chevron points right to match this app's
/// fully-RTL layout.
class BrandBackButton extends StatelessWidget {
  const BrandBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
