import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Bordered card grouping one part of the order details. Renders nothing
/// when [children] is empty.
class OrderDetailsSection extends StatelessWidget {
  const OrderDetailsSection({super.key, required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
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
          if (title != null) ...<Widget>[
            Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// A label above its value. Stacked rather than side by side so long values
/// (addresses, English names) get the full width instead of squeezing.
class OrderInfoField extends StatelessWidget {
  const OrderInfoField({
    super.key,
    required this.label,
    required this.value,
    this.maxLines = 2,
  });

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// `label ………… amount`; the label ellipsizes, the amount never moves.
class OrderAmountRow extends StatelessWidget {
  const OrderAmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.isEmphasized = false,
  });

  final String label;
  final String amount;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle style = TextStyle(
      fontFamily: 'Cairo',
      fontSize: isEmphasized ? 15 : 13,
      fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
      color: isEmphasized ? colors.textPrimary : colors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: style,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            maxLines: 1,
            style: style.copyWith(
              color: isEmphasized ? colors.primary : style.color,
            ),
          ),
        ],
      ),
    );
  }
}
