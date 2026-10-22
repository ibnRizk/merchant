import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/merchant_order.dart';
import '../utils/order_display.dart';

/// One row in the order history list: order number + status pill on top,
/// date/time and customer underneath, items count and price on the bottom.
///
/// Every text is width-bounded (inside [Expanded]/[Flexible]) with
/// `maxLines` + ellipsis, so long English or Arabic content can't overflow.
class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({
    super.key,
    required this.order,
    this.onTap,
  });

  final MerchantOrder order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextDirection textDirection = Directionality.of(context);
    final (Color pillBackground, Color pillText) = order
        .status
        .pillColors(colors);
    final String timeLabel = order.createdAt != null
        ? formatOrderTime(
            order.createdAt!,
            Localizations.localeOf(context).languageCode,
          )
        : '';
    final String customerName = order.customerLabel;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        order.number,
                        textDirection: textDirection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Directionality(
                        textDirection: textDirection,
                        child: StatusPill(
                          label: order.status.label,
                          background: pillBackground,
                          textColor: pillText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (timeLabel.isNotEmpty || customerName.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          timeLabel.isNotEmpty ? timeLabel : customerName,
                          textDirection: textDirection,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      if (timeLabel.isNotEmpty && customerName.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            customerName,
                            textDirection: textDirection,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        order.itemsLabel,
                        textDirection: textDirection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: order.status.isCancelled
                              ? colors.error
                              : colors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        order.amountLabel(context.currency),
                        textDirection: textDirection,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
