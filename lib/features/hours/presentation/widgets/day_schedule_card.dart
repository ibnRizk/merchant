import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/brand_toggle.dart';
import 'day_time_range.dart';

class DayScheduleEntry {
  const DayScheduleEntry({
    required this.dayName,
    required this.isOpen,
    required this.startTime,
    required this.endTime,
    this.isEditableRange = true,
  });

  final String dayName;
  final bool isOpen;
  final String startTime;
  final String endTime;
  final bool isEditableRange;

  DayScheduleEntry copyWith({bool? isOpen}) {
    return DayScheduleEntry(
      dayName: dayName,
      isOpen: isOpen ?? this.isOpen,
      startTime: startTime,
      endTime: endTime,
      isEditableRange: isEditableRange,
    );
  }
}

/// One row in the working-hours list: day name on the right, the time
/// range centered, and the open/closed toggle on the far left.
class DayScheduleCard extends StatelessWidget {
  const DayScheduleCard({
    super.key,
    required this.entry,
    required this.onToggle,
  });

  final DayScheduleEntry entry;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFF1F4)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 64,
            child: Text(
              entry.dayName,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: BrandColors.navy,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: DayTimeRange(
                startTime: entry.startTime,
                endTime: entry.endTime,
                isEditable: entry.isEditableRange,
              ),
            ),
          ),
          BrandToggle(value: entry.isOpen, onChanged: onToggle),
        ],
      ),
    );
  }
}
