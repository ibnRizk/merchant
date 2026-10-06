import 'package:flutter/material.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/wallet.dart';

/// The available balance, large, over the four figures it derives from.
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.currency,
  });

  final WalletBalance balance;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Strings.availableBalance,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  formatMoney(balance.availableBalance, currency),
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Figure(
                label: Strings.totalEarning,
                value: formatMoney(balance.totalEarning, currency),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Figure(
                label: Strings.totalWithdrawn,
                value: formatMoney(balance.totalWithdrawn, currency),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _Figure(
                label: Strings.pendingWithdraw,
                value: formatMoney(balance.pendingWithdraw, currency),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Figure(
                label: Strings.collectedCash,
                value: formatMoney(balance.collectedCash, currency),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
