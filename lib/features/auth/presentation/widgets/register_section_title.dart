import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Bold heading that groups related fields on the registration form.
class RegisterSectionTitle extends StatelessWidget {
  const RegisterSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 14),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}
