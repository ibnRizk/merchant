import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Centered store logo + store name + owner subtitle at the top of the
/// profile screen. Falls back to a storefront icon when there's no logo.
class ProfileAvatarBlock extends StatelessWidget {
  const ProfileAvatarBlock({
    super.key,
    required this.storeName,
    required this.subtitle,
    this.logoUrl,
  });

  final String storeName;
  final String subtitle;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Widget fallback = ColoredBox(
      color: colors.secondary,
      child: Icon(Icons.storefront_outlined, size: 36, color: colors.primary),
    );

    return Column(
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: colors.primary, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: logoUrl == null
                ? fallback
                : CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => fallback,
                    errorWidget: (_, __, ___) => fallback,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          storeName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        if (subtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
