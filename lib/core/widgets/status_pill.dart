import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Small pill used for counts and status labels across the app (order
/// status, product availability, etc). Defaults to the primary-tinted
/// peach/orange look; pass [background]/[textColor] for other statuses
/// (e.g. green "delivered", red "cancelled", gray "unavailable").
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.background,
    this.textColor,
  });

  final String label;

  /// Default to [AppColors.primaryLight]/[AppColors.primary] when omitted —
  /// kept nullable because a context-aware default can't be a compile-time
  /// constant.
  final Color? background;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background ?? colors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor ?? colors.primary,
        ),
      ),
    );
  }
}
