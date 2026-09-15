import 'package:flutter/material.dart';

import '../../../../core/widgets/tab_placeholder.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(
      icon: Icons.menu_book_outlined,
      title: 'المنيو',
    );
  }
}
