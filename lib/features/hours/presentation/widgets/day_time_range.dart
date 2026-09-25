import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import 'time_chip.dart';

/// Opening/closing time pair for one day, as two tappable [TimeChip]s
/// separated by a dash.
class DayTimeRange extends StatelessWidget {
  const DayTimeRange({
    super.key,
    required this.openingTime,
    required this.closingTime,
    required this.onTapOpening,
    required this.onTapClosing,
  });

  final String openingTime;
  final String closingTime;
  final VoidCallback onTapOpening;
  final VoidCallback onTapClosing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TimeChip(label: openingTime, onTap: onTapOpening),
        const SizedBox(width: 8),
        Text(
          '—',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(width: 8),
        TimeChip(label: closingTime, onTap: onTapClosing),
      ],
    );
  }
}
