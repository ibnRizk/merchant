import 'package:flutter/material.dart';

import '../utils/values/brand_colors.dart';

/// Circular back button for standalone-pushed screens that don't use the
/// app's default [AppBar]. The chevron points right to match this app's
/// fully-RTL layout.
class BrandBackButton extends StatelessWidget {
  const BrandBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BrandColors.border),
        ),
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: BrandColors.navy,
        ),
      ),
    );
  }
}
