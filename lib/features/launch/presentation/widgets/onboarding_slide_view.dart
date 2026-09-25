import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import 'onboarding_slide.dart';

/// One onboarding page: an icon illustration, a title and a description.
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: <Widget>[
          _Illustration(icon: slide.icon),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              height: 1.6,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      width: 220,
      height: 220,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 140,
        height: 140,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.secondary, width: 4),
        ),
        child: Icon(icon, size: 64, color: colors.primary),
      ),
    );
  }
}
