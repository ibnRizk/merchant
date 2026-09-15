import 'package:flutter/material.dart';

import '../../../../core/widgets/tab_placeholder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(
      icon: Icons.person_outline,
      title: 'حسابي',
    );
  }
}
