import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/wallet.dart';
import '../utils/wallet_display.dart';

/// One payout request: amount, date and status.
class WithdrawRequestTile extends StatelessWidget {
  const WithdrawRequestTile({
    super.key,
    required this.request,
    required this.currency,
  });

  final WithdrawRequest request;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final (Color background, Color text) = request.status.pillColors(colors);
    final DateTime? createdAt = request.createdAt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  formatMoney(request.amount, currency),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (createdAt != null)
                  Text(
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).languageCode,
                    ).format(createdAt),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          StatusPill(
            label: request.status.label,
            background: background,
            textColor: text,
          ),
        ],
      ),
    );
  }
}
