import 'package:flutter/material.dart';

import '../utils/values/brand_colors.dart';

/// Screen title with a small orange pill action button on the left (e.g.
/// "حفظ"). Shared by the working-hours and profile screens.
class TitleActionHeader extends StatelessWidget {
  const TitleActionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: BrandColors.navy,
          ),
        ),
        Material(
          color: BrandColors.orange,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
