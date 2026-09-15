import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/status_pill.dart';

class OrderHistoryEntry {
  const OrderHistoryEntry({
    required this.orderId,
    required this.statusLabel,
    required this.isCancelled,
    required this.meta,
    required this.price,
    required this.itemsLabel,
  });

  final String orderId;
  final String statusLabel;
  final bool isCancelled;
  final String meta;
  final String price;
  final String itemsLabel;
}

/// One row in the order history list: status pill + order id on top,
/// date/time and customer underneath, items count and price on the bottom.
class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({super.key, required this.entry});

  final OrderHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final Color itemsColor =
        entry.isCancelled ? BrandColors.cancelledText : BrandColors.textGray;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.orderId,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: BrandColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: entry.statusLabel,
                background: entry.isCancelled
                    ? BrandColors.cancelledBg
                    : BrandColors.statusBg,
                textColor: entry.isCancelled
                    ? BrandColors.cancelledText
                    : BrandColors.statusText,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.meta,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: BrandColors.textGray,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                entry.itemsLabel,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: itemsColor,
                ),
              ),
              Text(
                entry.price,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
