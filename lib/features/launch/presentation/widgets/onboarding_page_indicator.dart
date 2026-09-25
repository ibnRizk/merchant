import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Row of dots; the current page's dot is stretched into a pill.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? colors.primary : colors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
