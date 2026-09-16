import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Navy "SSM" badge shown at the top of the login screen.
class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'SSM',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: scheme.onSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
