import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_status.dart';
import '../utils/order_display.dart';
import 'order_card_header.dart';
import 'order_item_row.dart';
import 'order_progress_stepper.dart';
import 'system_notice_banner.dart';

/// An accepted order the merchant still has to move: header, the 3-step
/// progress bar, lines and the next action ("start preparing", "ready for
/// pickup", or "retry dispatch" when no driver was found).
class ActiveOrderDetailCard extends StatelessWidget {
  const ActiveOrderDetailCard({
    super.key,
    required this.order,
    required this.onAdvance,
    required this.onTap,
    this.isBusy = false,
  });

  final MerchantOrder order;
  final VoidCallback onAdvance;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final (Color pillBackground, Color pillText) = order.status.pillColors(
      colors,
    );
    final OrderAction? next = order.status.nextAction;
    final String currency = context.currency;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OrderCardHeader(
                title: order.number,
                subtitle: order.customerName.isEmpty
                    ? order.amountLabel(currency)
                    : '${Strings.customerPrefix}${order.customerLabel}',
                trailingWidget: StatusPill(
                  label: order.status.label,
                  background: pillBackground,
                  textColor: pillText,
                ),
              ),
              const SizedBox(height: 16),
              OrderProgressStepper(steps: progressSteps(order.status, colors)),
              const SizedBox(height: 12),
              for (final line in order.lines) OrderItemRow(line: line),
              if (next != null) ...<Widget>[
                const SizedBox(height: 12),
                PrimaryButton(
                  label: next.label,
                  isLoading: isBusy,
                  onPressed: onAdvance,
                ),
              ],
              if (next == OrderAction.readyForPickup) ...<Widget>[
                const SizedBox(height: 12),
                SystemNoticeBanner(text: Strings.systemWillNotifyDriver),
              ],
              if (next == OrderAction.retryDispatch) ...<Widget>[
                const SizedBox(height: 12),
                SystemNoticeBanner(text: Strings.assignmentFailedHint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// accepted → preparing → ready: reached steps in brand colors.
List<ProgressStep> progressSteps(OrderStatus status, AppColors colors) {
  final int reached = switch (status) {
    OrderStatus.accepted => 1,
    OrderStatus.preparing => 2,
    _ => 3,
  };
  return <ProgressStep>[
    ProgressStep(label: Strings.statusAccepted, color: colors.primary),
    ProgressStep(
      label: Strings.statusPreparing,
      color: reached >= 2 ? colors.secondary : colors.border,
    ),
    ProgressStep(
      label: Strings.statusReadyForPickup,
      color: reached >= 3 ? colors.success : colors.border,
    ),
  ];
}
