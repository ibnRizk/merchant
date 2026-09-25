import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_toggle.dart';
import 'day_time_range.dart';

/// One row in the working-hours list: day name on the right, the time
/// range (or "Closed") centered, and the open/closed toggle on the far left.
class DayScheduleCard extends StatelessWidget {
  const DayScheduleCard({
    super.key,
    required this.dayName,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.onToggle,
    required this.onTapOpening,
    required this.onTapClosing,
  });

  final String dayName;
  final bool isOpen;

  /// Formatted for display; ignored while the day is closed.
  final String openingTime;
  final String closingTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapOpening;
  final VoidCallback onTapClosing;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 64,
            child: Text(
              dayName,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: isOpen
                  ? DayTimeRange(
                      openingTime: openingTime,
                      closingTime: closingTime,
                      onTapOpening: onTapOpening,
                      onTapClosing: onTapClosing,
                    )
                  : Text(
                      Strings.closed,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
            ),
          ),
          BrandToggle(value: isOpen, onChanged: onToggle),
        ],
      ),
    );
  }
}
