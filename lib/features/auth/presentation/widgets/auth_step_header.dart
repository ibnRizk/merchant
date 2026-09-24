import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Centered title + subtitle used at the top of the auth flow screens.
class AuthStepHeader extends StatelessWidget {
  const AuthStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.5,
            height: 1.5,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
