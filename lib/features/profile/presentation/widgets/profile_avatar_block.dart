import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

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
    return Column(
      children: <Widget>[
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BrandColors.navy,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            size: 36,
            color: BrandColors.orange,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          storeName,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: BrandColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: BrandColors.textGray,
          ),
        ),
      ],
    );
  }
}
