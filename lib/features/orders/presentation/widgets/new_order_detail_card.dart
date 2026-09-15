import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFF1F4)),
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
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: BrandColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: BrandColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEFF1F4), height: 1),
          const SizedBox(height: 8),
          for (final OrderLineItem item in items)
            OrderItemRow(name: item.name, price: item.price),
          const SizedBox(height: 8),
          TipBanner(boldPrefix: noteLabel, text: noteText),
          const SizedBox(height: 16),
          OrderActionButtons(onAccept: onAccept, onReject: onReject),
          const SizedBox(height: 14),
          const ReadyForPickupBanner(
            prefix: 'بعد الضغط ',
            highlighted: '«جاهز للاستلام»',
            subtitle: 'سيتم إرسال النظام تلقائياً لأقرب مندوب متصل',
          ),
        ],
      ),
    );
  }
}
