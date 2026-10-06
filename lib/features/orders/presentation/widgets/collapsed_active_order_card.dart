import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/merchant_order.dart';
import '../utils/order_display.dart';

/// Compact row for an order the merchant has handed over (dispatch and
/// delivery stages): number + status on top, time/customer underneath.
/// When no driver accepted it, a "Retry dispatch" button follows.
class CollapsedActiveOrderCard extends StatelessWidget {
  const CollapsedActiveOrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onRetryDispatch,
    this.isBusy = false,
  });

  final MerchantOrder order;
  final VoidCallback? onTap;

  /// Shown only while the order can be re-dispatched.
  final VoidCallback? onRetryDispatch;

  /// A request for this order is in flight.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String subtitle = order.metaLine(
      Localizations.localeOf(context).languageCode,
    );
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      order.number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
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
                    child: Text(
                      order.status.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (onRetryDispatch != null &&
                  order.status.canRetryDispatch) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  Strings.noDriverAccepted,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: Strings.retryDispatch,
                  isLoading: isBusy,
                  onPressed: onRetryDispatch!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
