import 'package:flutter/material.dart';

import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../utils/order_display.dart';
import 'order_action_buttons.dart';
import 'order_card_header.dart';
import 'order_item_row.dart';

/// A new order waiting for the merchant: number/time/price header, lines
/// (when the list embeds them), customer note and accept/reject actions.
class NewOrderDetailCard extends StatelessWidget {
  const NewOrderDetailCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onTap,
    this.isBusy = false,
  });

  final MerchantOrder order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  /// Opens the order's details.
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
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
                subtitle: order.metaLine(
                  Localizations.localeOf(context).languageCode,
                ),
                trailing: order.amountLabel,
              ),
              const SizedBox(height: 12),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 8),
              if (order.lines.isEmpty)
                Text(
                  order.itemsLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                )
              else
                for (final OrderLine line in order.lines)
                  OrderItemRow(line: line),
              if (order.note.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                TipBanner(
                  boldPrefix: Strings.customerNote,
                  text: order.note.bidiIsolated,
                ),
              ],
              const SizedBox(height: 16),
              OrderActionButtons(
                onAccept: onAccept,
                onReject: onReject,
                isBusy: isBusy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
