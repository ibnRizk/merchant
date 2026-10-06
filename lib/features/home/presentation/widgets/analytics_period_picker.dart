import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/entities/store_analytics.dart';

/// One row of chips choosing the analytics range.
class AnalyticsPeriodPicker extends StatelessWidget {
  const AnalyticsPeriodPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onSelected;

  static String labelOf(AnalyticsPeriod period) => switch (period) {
    AnalyticsPeriod.last7Days => Strings.last7Days,
    AnalyticsPeriod.last30Days => Strings.last30Days,
    AnalyticsPeriod.last90Days => Strings.last90Days,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Row(
      children: <Widget>[
        for (final AnalyticsPeriod period
            in AnalyticsPeriod.values) ...<Widget>[
          if (period != AnalyticsPeriod.values.first) const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(
                  labelOf(period),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              selected: period == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(period),
              labelStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: period == selected
                    ? colors.primary
                    : colors.textSecondary,
              ),
              selectedColor: colors.primaryLight,
              backgroundColor: colors.surface,
              side: BorderSide(
                color: period == selected ? colors.primary : colors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
