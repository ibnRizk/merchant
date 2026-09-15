import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Single-line green notice, e.g. confirming the system will notify a
/// delivery driver automatically.
class SystemNoticeBanner extends StatelessWidget {
  const SystemNoticeBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BrandColors.statusBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: BrandColors.statusText,
        ),
      ),
    );
  }
}
