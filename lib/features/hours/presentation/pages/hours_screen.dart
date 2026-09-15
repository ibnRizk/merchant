import 'package:flutter/material.dart';

import '../../../../core/widgets/tab_placeholder.dart';

class HoursScreen extends StatelessWidget {
  const HoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(
      icon: Icons.access_time_outlined,
      title: 'الساعات',
    );
  }
}
