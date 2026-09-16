import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import 'time_chip.dart';

/// Start/end time pair for one day. Renders as two tappable [TimeChip]s
/// separated by a dash, or — when [isEditable] is false — as a single plain
/// text range (used for days with a non-standard split schedule).
class DayTimeRange extends StatelessWidget {
  const DayTimeRange({
    super.key,
    required this.startTime,
    required this.endTime,
    this.isEditable = true,
  });

  final String startTime;
  final String endTime;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    if (!isEditable) {
      return Text(
        '$endTime  —  $startTime',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TimeChip(label: endTime),
        const SizedBox(width: 8),
        Text(
          '—',
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        const SizedBox(width: 8),
        TimeChip(label: startTime),
      ],
    );
  }
}
