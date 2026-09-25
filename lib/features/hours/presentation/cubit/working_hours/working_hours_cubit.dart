import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/clock_time.dart';
import '../../../domain/entities/day_schedule.dart';
import '../../../domain/repos/working_hours_repository.dart';
import 'working_hours_state.dart';

export 'working_hours_state.dart';

/// Loads the weekly schedule, holds the merchant's edits locally, and saves
/// the whole week in one request.
class WorkingHoursCubit extends Cubit<WorkingHoursState> {
  final WorkingHoursRepository _repository;

  WorkingHoursCubit({required WorkingHoursRepository repository})
    : _repository = repository,
      super(const WorkingHoursLoading());

  Future<void> load() async {
    emit(const WorkingHoursLoading());
    final result = await _repository.getWorkingHours();
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => WorkingHoursLoadFailure(failure.displayMessage),
        WorkingHoursEditing.new,
      ),
    );
  }

  void setOpen(int day, bool isOpen) =>
      _edit(day, (DaySchedule d) => d.withOpen(isOpen));

  void setOpeningTime(int day, ClockTime time) =>
      _edit(day, (DaySchedule d) => d.withOpeningTime(time));

  void setClosingTime(int day, ClockTime time) =>
      _edit(day, (DaySchedule d) => d.withClosingTime(time));

  Future<void> save() async {
    final WorkingHoursState current = state;
    if (current is! WorkingHoursReady || current is WorkingHoursSaving) return;

    emit(WorkingHoursSaving(current.days));
    final result = await _repository.saveWorkingHours(current.days);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) =>
            WorkingHoursSaveFailure(current.days, failure.displayMessage),
        WorkingHoursSaved.new,
      ),
    );
  }

  /// Ignored while saving, so the request and the screen can't disagree.
  void _edit(int day, DaySchedule Function(DaySchedule) change) {
    final WorkingHoursState current = state;
    if (current is! WorkingHoursReady || current is WorkingHoursSaving) return;

    emit(
      WorkingHoursEditing(<DaySchedule>[
        for (final DaySchedule d in current.days) d.day == day ? change(d) : d,
      ]),
    );
  }
}
