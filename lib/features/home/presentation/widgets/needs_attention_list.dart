import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/action_card.dart';
import '../../domain/entities/dashboard_stats.dart';

/// "Needs your attention": a card for new orders and one for orders being
/// processed, each only when it has orders; a calm note when neither does.
class NeedsAttentionList extends StatelessWidget {
  const NeedsAttentionList({
    super.key,
    required this.stats,
    required this.onOpenNewOrders,
    required this.onOpenActiveOrders,
  });

  final DashboardStats stats;
  final VoidCallback onOpenNewOrders;
  final VoidCallback onOpenActiveOrders;

  @override
  Widget build(BuildContext context) {
    if (!stats.needsAttention) {
      final AppColors colors = context.colors;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.check_circle_outline, color: colors.success),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                Strings.nothingNeedsAttention,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (stats.newOrders > 0)
          ActionCard(
            title: '${stats.newOrders} ${Strings.newOrdersTitle}',
            subtitle: Strings.waitingForAcceptance,
            actionLabel: Strings.openOrders,
            onTap: onOpenNewOrders,
          ),
        if (stats.newOrders > 0 && stats.processingOrders > 0)
          const SizedBox(height: 12),
        if (stats.processingOrders > 0)
          ActionCard(
            title: '${stats.processingOrders} ${Strings.processingOrdersTitle}',
            subtitle: Strings.notifyDriverWhenReady,
            actionLabel: Strings.view,
            onTap: onOpenActiveOrders,
          ),
      ],
    );
  }
}
