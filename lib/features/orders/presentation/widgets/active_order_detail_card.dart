import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_pill.dart';
import 'new_order_detail_card.dart' show OrderLineItem;
import 'order_item_row.dart';
import 'order_progress_stepper.dart';
import 'system_notice_banner.dart';

/// Full detail card for the currently in-progress order: id/customer/status
/// header, the 3-step progress bar, item list, a single primary action and
/// a system notice — composed from the smaller order widgets.
class ActiveOrderDetailCard extends StatelessWidget {
  const ActiveOrderDetailCard({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.statusLabel,
    required this.steps,
    required this.items,
    required this.ctaLabel,
    required this.onCtaPressed,
    required this.noticeText,
  });

  final String orderId;
  final String customerName;
  final String statusLabel;
  final List<ProgressStep> steps;
  final List<OrderLineItem> items;
  final String ctaLabel;
  final VoidCallback onCtaPressed;
  final String noticeText;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      orderId,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'العميل: $customerName',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusPill(label: statusLabel),
            ],
          ),
          const SizedBox(height: 16),
          OrderProgressStepper(steps: steps),
          const SizedBox(height: 16),
          for (final OrderLineItem item in items)
            OrderItemRow(name: item.name, price: item.price),
          const SizedBox(height: 16),
          PrimaryButton(label: ctaLabel, onPressed: onCtaPressed),
          const SizedBox(height: 12),
          SystemNoticeBanner(text: noticeText),
        ],
      ),
    );
  }
}
