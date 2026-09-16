import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Centered navy avatar + store name + category/location subtitle at the
/// top of the profile screen.
class ProfileAvatarBlock extends StatelessWidget {
  const ProfileAvatarBlock({
    super.key,
    required this.storeName,
    required this.subtitle,
  });

  final String storeName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      children: <Widget>[
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(Icons.storefront_outlined, size: 36, color: colors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          storeName,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
