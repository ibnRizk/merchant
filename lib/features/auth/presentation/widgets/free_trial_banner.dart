import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Light green banner announcing the free onboarding phase.
class FreeTrialBanner extends StatelessWidget {
  const FreeTrialBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BrandColors.statusBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: BrandColors.statusText,
        ),
      ),
    );
  }
}
