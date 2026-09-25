import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../../../../core/widgets/title_action_header.dart';
import '../../domain/entities/clock_time.dart';
import '../../domain/entities/day_schedule.dart';
import '../cubit/working_hours/working_hours_cubit.dart';
import '../widgets/day_schedule_card.dart';

/// Working-hours tab body. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold, and
/// [WorkingHoursCubit] by the home route.
class HoursScreen extends StatelessWidget {
  const HoursScreen({super.key});

  /// The week as merchants read it, Saturday first. API days: 0 = Sunday.
  static const List<int> _displayOrder = <int>[6, 0, 1, 2, 3, 4, 5];

  static String _dayName(int day) => switch (day) {
    0 => Strings.sunday,
    1 => Strings.monday,
    2 => Strings.tuesday,
    3 => Strings.wednesday,
    4 => Strings.thursday,
    5 => Strings.friday,
    _ => Strings.saturday,
  };

  @override
  Widget build(BuildContext context) {
    // Labels come from the global `Strings.*.tr`, so a language switch has
    // to rebuild this screen for them to refresh.
    context.watch<LocaleCubit>();

    return BlocListener<WorkingHoursCubit, WorkingHoursState>(
      listenWhen: (_, WorkingHoursState current) =>
          current is WorkingHoursSaved || current is WorkingHoursSaveFailure,
      listener: (BuildContext context, WorkingHoursState state) =>
          switch (state) {
            WorkingHoursSaveFailure(:final message) => showBrandSnackBar(
              context,
              message,
              isError: true,
            ),
            _ => showBrandSnackBar(context, Strings.workingHoursSaved),
          },
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<WorkingHoursCubit, WorkingHoursState>(
          builder: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WorkingHoursState state) {
    final WorkingHoursCubit cubit = context.read<WorkingHoursCubit>();
    final bool isSaving = state is WorkingHoursSaving;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TitleActionHeader(
            title: Strings.workingHours,
            actionLabel: Strings.save,
            isLoading: isSaving,
            onActionTap: state is WorkingHoursReady ? cubit.save : null,
          ),
          const SizedBox(height: 16),
          TipBanner(
            boldPrefix: Strings.localTimeNote.split('-')[0],
            text:
                ' - ${Strings.localTimeNote.split('-').length > 1 ? Strings.localTimeNote.split('-')[1].trim() : ''}',
          ),
          const SizedBox(height: 16),
          ...switch (state) {
            WorkingHoursLoading() => <Widget>[const SectionLoadingView()],
            WorkingHoursLoadFailure(:final message) => <Widget>[
              RetryErrorView(message: message, onRetry: cubit.load),
            ],
            WorkingHoursReady(:final days) => <Widget>[
              ..._buildDays(context, cubit, days),
              const SizedBox(height: 10),
              PrimaryButton(
                label: Strings.saveWorkingHours,
                isLoading: isSaving,
                onPressed: cubit.save,
              ),
            ],
          },
        ],
      ),
    );
  }

  List<Widget> _buildDays(
    BuildContext context,
    WorkingHoursCubit cubit,
    List<DaySchedule> days,
  ) {
    final Map<int, DaySchedule> byDay = <int, DaySchedule>{
      for (final DaySchedule d in days) d.day: d,
    };
    return <Widget>[
      for (final int day in _displayOrder)
        if (byDay[day] case final DaySchedule schedule) ...<Widget>[
          DayScheduleCard(
            dayName: _dayName(day),
            isOpen: schedule.isOpen,
            openingTime: _format(context, schedule.openingTime),
            closingTime: _format(context, schedule.closingTime),
            onToggle: (bool isOpen) => cubit.setOpen(day, isOpen),
            onTapOpening: () => _pickTime(
              context,
              schedule.openingTime ?? DaySchedule.defaultOpening,
              (ClockTime time) => cubit.setOpeningTime(day, time),
            ),
            onTapClosing: () => _pickTime(
              context,
              schedule.closingTime ?? DaySchedule.defaultClosing,
              (ClockTime time) => cubit.setClosingTime(day, time),
            ),
          ),
          const SizedBox(height: 10),
        ],
    ];
  }

  /// Follows the device's locale and 12/24-hour setting.
  static String _format(BuildContext context, ClockTime? time) => time == null
      ? '–'
      : MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(TimeOfDay(hour: time.hour, minute: time.minute));

  static Future<void> _pickTime(
    BuildContext context,
    ClockTime initial,
    ValueChanged<ClockTime> onPicked,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    if (picked != null) onPicked(ClockTime(picked.hour, picked.minute));
  }
}
