import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
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
    final AppColors colors = context.colors;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                label: Strings.todaysOrders,
                value: ordersToday,
                background: colors.surface,
                valueColor: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: Strings.newOrders,
                value: newOrders,
                background: colors.primaryLight,
                valueColor: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: StatCard(
                label: Strings.todaysRevenue,
                value: revenueToday,
                suffix: Strings.currencySar,
                background: colors.surface,
                valueColor: colors.textPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: Strings.processingOrders,
                value: preparingOrders,
                background: colors.primaryLight,
                valueColor: colors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
