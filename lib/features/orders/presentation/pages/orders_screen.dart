import 'package:flutter/material.dart';

import '../../../../core/widgets/tab_placeholder.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholder(
      icon: Icons.receipt_long_outlined,
      title: 'الطلبات',
    );
  }
}
