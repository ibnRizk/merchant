import 'package:flutter/material.dart';

import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../../../../core/widgets/title_action_header.dart';
import '../widgets/day_schedule_card.dart';

/// Working-hours tab body — composed from small widgets under
/// `presentation/widgets/`. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold.
class HoursScreen extends StatefulWidget {
  const HoursScreen({super.key});

  @override
  State<HoursScreen> createState() => _HoursScreenState();
}

class _HoursScreenState extends State<HoursScreen> {
  late List<DayScheduleEntry> _days;

  @override
  void initState() {
    super.initState();
    _days = <DayScheduleEntry>[
      DayScheduleEntry(
        dayName: Strings.saturday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: 'ص 10:00',
      ),
      DayScheduleEntry(
        dayName: Strings.sunday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: 'ص 10:00',
      ),
      DayScheduleEntry(
        dayName: Strings.monday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: 'ص 10:00',
      ),
      DayScheduleEntry(
        dayName: Strings.tuesday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: 'ص 10:00',
      ),
      DayScheduleEntry(
        dayName: Strings.wednesday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: 'ص 10:00',
      ),
      DayScheduleEntry(
        dayName: Strings.thursday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: 'ص 10:00',
      ),
      DayScheduleEntry(
        dayName: Strings.friday,
        isOpen: true,
        startTime: 'ص 02:00',
        endTime: '16:00',
        isEditableRange: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TitleActionHeader(
              title: Strings.workingHours,
              actionLabel: Strings.save,
              onActionTap: () =>
                  showBrandSnackBar(context, 'تم حفظ ساعات العمل بنجاح'),
            ),
            const SizedBox(height: 16),
            TipBanner(
              boldPrefix: Strings.localTimeNote.split('-')[0],
              text: ' - ${Strings.localTimeNote.split('-').length > 1 ? Strings.localTimeNote.split('-')[1].trim() : ''}',
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < _days.length; i++) ...<Widget>[
              DayScheduleCard(
                entry: _days[i],
                onToggle: (bool value) =>
                    setState(() => _days[i] = _days[i].copyWith(isOpen: value)),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            PrimaryButton(
              label: Strings.saveWorkingHours,
              onPressed: () =>
                  showBrandSnackBar(context, 'تم حفظ ساعات العمل بنجاح'),
            ),
          ],
        ),
      ),
    );
  }
}
