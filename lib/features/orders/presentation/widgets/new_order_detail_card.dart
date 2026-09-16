import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/tip_banner.dart';
import 'order_action_buttons.dart';
import 'order_item_row.dart';
import 'ready_for_pickup_banner.dart';

class OrderLineItem {
  const OrderLineItem({required this.name, required this.price});

  final String name;
  final String price;
}

/// Full detail card for the currently-active new order: id/time/price
/// header, item list, customer note, accept/reject actions and the
/// "ready for pickup" explainer — composed from the smaller order widgets.
class NewOrderDetailCard extends StatelessWidget {
  const NewOrderDetailCard({
    super.key,
    required this.orderId,
    required this.meta,
    required this.price,
    required this.items,
    required this.noteLabel,
    required this.noteText,
    required this.onAccept,
    required this.onReject,
  });

  final String orderId;
  final String meta;
  final String price;
  final List<OrderLineItem> items;
  final String noteLabel;
  final String noteText;
  final VoidCallback onAccept;
  final VoidCallback onReject;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      orderId,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      textAlign: TextAlign.start,
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
              Text(
                price,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: 8),
          for (final OrderLineItem item in items)
            OrderItemRow(name: item.name, price: item.price),
          const SizedBox(height: 8),
          TipBanner(boldPrefix: noteLabel, text: noteText),
          const SizedBox(height: 16),
          OrderActionButtons(onAccept: onAccept, onReject: onReject),
          const SizedBox(height: 14),
          ReadyForPickupBanner(
            prefix: Strings.afterPressing,
            highlighted: Strings.readyForPickupQuoted,
            subtitle: Strings.systemWillNotifyDriver,
          ),
        ],
      ),
    );
  }
}
