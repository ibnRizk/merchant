import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// "أهلاً بك" title + subtitle shown under the logo.
class LoginHeaderText extends StatelessWidget {
  const LoginHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          'أهلاً بك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: BrandColors.navy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'سجّل الدخول لإدارة متجرك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
