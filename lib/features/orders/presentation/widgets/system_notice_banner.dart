import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Single-line green notice, e.g. confirming the system will notify a
/// delivery driver automatically.
class SystemNoticeBanner extends StatelessWidget {
  const SystemNoticeBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.successContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.success,
        ),
      ),
    );
  }
}
