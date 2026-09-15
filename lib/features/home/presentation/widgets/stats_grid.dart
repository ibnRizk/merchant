import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import 'stat_card.dart';

/// 2x2 grid of [StatCard]s: white/navy cards on the right column, peach/
/// orange cards on the left column.
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.ordersToday,
    required this.newOrders,
    required this.revenueToday,
    required this.preparingOrders,
  });

  final String ordersToday;
  final String newOrders;
  final String revenueToday;
  final String preparingOrders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                label: 'طلبات اليوم',
                value: ordersToday,
                background: Colors.white,
                valueColor: BrandColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'طلبات جديدة',
                value: newOrders,
                background: BrandColors.peachBg,
                valueColor: BrandColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                label: 'إيرادات اليوم',
                value: revenueToday,
                suffix: 'ر.س',
                background: Colors.white,
                valueColor: BrandColors.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'قيد التجهيز',
                value: preparingOrders,
                background: BrandColors.peachBg,
                valueColor: BrandColors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
