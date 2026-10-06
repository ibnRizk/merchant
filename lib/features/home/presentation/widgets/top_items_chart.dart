import 'package:flutter/material.dart';

import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/store_analytics.dart';

/// Best sellers as horizontal bars in one hue, each scaled to the top
/// seller and labeled with its units sold.
class TopItemsChart extends StatelessWidget {
  const TopItemsChart({super.key, required this.items, this.maxItems = 5});

  final List<TopItem> items;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle labelStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
    if (items.isEmpty) {
      return Text(
        Strings.noSalesInPeriod,
        style: labelStyle.copyWith(color: colors.textSecondary),
      );
    }

    final List<TopItem> shown = items.take(maxItems).toList();
    final int top = shown
        .map((TopItem item) => item.quantity)
        .fold<int>(0, (int a, int b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final TopItem item in shown)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.name.bidiIsolated,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.quantity} ${Strings.unitsSold}',
                      style: labelStyle.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      height: 8,
                      // A sliver stays visible for a zero, so the row
                      // never reads as missing data.
                      width: top == 0
                          ? 4
                          : (box.maxWidth * item.quantity / top).clamp(
                              4,
                              box.maxWidth,
                            ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
