import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Light green banner announcing the free onboarding phase. Shared by the
/// login screen and the merchant profile screen.
class FreeTrialBanner extends StatelessWidget {
  const FreeTrialBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.successContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: colors.success,
        ),
      ),
    );
  }
}
