import 'package:flutter/material.dart';

import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
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
  final List<DayScheduleEntry> _days = <DayScheduleEntry>[
    const DayScheduleEntry(
      dayName: 'السبت',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: 'ص 10:00',
    ),
    const DayScheduleEntry(
      dayName: 'الأحد',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: 'ص 10:00',
    ),
    const DayScheduleEntry(
      dayName: 'الإثنين',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: 'ص 10:00',
    ),
    const DayScheduleEntry(
      dayName: 'الثلاثاء',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: 'ص 10:00',
    ),
    const DayScheduleEntry(
      dayName: 'الأربعاء',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: 'ص 10:00',
    ),
    const DayScheduleEntry(
      dayName: 'الخميس',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: 'ص 10:00',
    ),
    const DayScheduleEntry(
      dayName: 'الجمعة',
      isOpen: true,
      startTime: 'ص 02:00',
      endTime: '16:00',
      isEditableRange: false,
    ),
  ];

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
              title: 'ساعات العمل',
              actionLabel: 'حفظ',
              onActionTap: () =>
                  showBrandSnackBar(context, 'تم حفظ ساعات العمل بنجاح'),
            ),
            const SizedBox(height: 16),
            const TipBanner(
              boldPrefix: 'التوقيت المحلي: محافظة نبرة',
              text: ' - يمكنك تغيير ساعات كل يوم.',
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
              label: 'حفظ ساعات العمل',
              onPressed: () =>
                  showBrandSnackBar(context, 'تم حفظ ساعات العمل بنجاح'),
            ),
          ],
        ),
      ),
    );
  }
}
