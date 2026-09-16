import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Small rounded chip showing one time value inside a [DayTimeRange].
class TimeChip extends StatelessWidget {
  const TimeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}
