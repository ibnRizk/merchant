import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// "أهلاً بك" title + subtitle shown under the logo.
class LoginHeaderText extends StatelessWidget {
  const LoginHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      children: <Widget>[
        Text(
          'أهلاً بك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'سجّل الدخول لإدارة متجرك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
