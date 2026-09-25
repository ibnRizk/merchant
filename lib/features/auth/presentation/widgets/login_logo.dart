import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';

/// SSM brand logo shown at the top of the login screen.
class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: AppLogo(size: 96));
  }
}
