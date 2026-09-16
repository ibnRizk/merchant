import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Navy avatar + greeting/store-name pair shown at the top of the dashboard.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.storeName,
    required this.avatarLetter,
  });

  final String greeting;
  final String storeName;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greeting,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                storeName,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            avatarLetter,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
