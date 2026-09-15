import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Small rounded chip showing one time value inside a [DayTimeRange].
class TimeChip extends StatelessWidget {
  const TimeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: BrandColors.fieldFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BrandColors.navy,
        ),
      ),
    );
  }
}
