import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../domain/entities/order_line.dart';
import '../utils/order_display.dart';

/// One order line: `name × qty` (and its extras) at the start, the line
/// total at the end. The name takes the remaining width and wraps to at
/// most two lines, so long English names can't push the price off screen.
class OrderItemRow extends StatelessWidget {
  const OrderItemRow({super.key, required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String extras = line.extrasLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  line.titleLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                if (extras.isNotEmpty)
                  Text(
                    extras,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            line.totalLabel,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
