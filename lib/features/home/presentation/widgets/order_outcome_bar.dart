import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/store_analytics.dart';

/// Delivered / cancelled / other as one part-to-whole bar. The legend
/// carries every count, so the colors are never the only signal.
class OrderOutcomeBar extends StatelessWidget {
  const OrderOutcomeBar({super.key, required this.analytics});

  final StoreAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final List<_Segment> segments = <_Segment>[
      _Segment(Strings.delivered, analytics.deliveredOrders, colors.success),
      _Segment(
        Strings.cancelledStatus,
        analytics.cancelledOrders,
        colors.error,
      ),
      _Segment(Strings.otherOrders, analytics.otherOrders, colors.info),
    ];
    final List<_Segment> visible = <_Segment>[
      for (final _Segment segment in segments)
        if (segment.count > 0) segment,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: visible.isEmpty
                ? ColoredBox(color: colors.border)
                : Row(
                    children: <Widget>[
                      for (int i = 0; i < visible.length; i++) ...<Widget>[
                        // A 2px surface gap keeps adjacent fills apart.
                        if (i > 0) const SizedBox(width: 2),
                        Expanded(
                          flex: visible[i].count,
                          child: ColoredBox(color: visible[i].color),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: <Widget>[
            for (final _Segment segment in segments)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: segment.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${segment.label} ${segment.count}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _Segment {
  final String label;
  final int count;
  final Color color;

  const _Segment(this.label, this.count, this.color);
}
