import 'package:flutter/material.dart';

import '../utils/values/brand_colors.dart';

/// Small pill used for counts and status labels across the app (order
/// status, product availability, etc). Defaults to peach/orange; pass
/// [background]/[textColor] for other statuses (e.g. green "delivered",
/// red "cancelled", gray "unavailable").
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.background = BrandColors.peachBg,
    this.textColor = BrandColors.orange,
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
