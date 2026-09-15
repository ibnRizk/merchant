import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Navy "SSM" badge shown at the top of the login screen.
class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BrandColors.navy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'SSM',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
