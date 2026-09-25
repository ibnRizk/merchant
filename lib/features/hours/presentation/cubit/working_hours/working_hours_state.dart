import '../../../domain/entities/day_schedule.dart';

sealed class WorkingHoursState {
  const WorkingHoursState();
}

final class WorkingHoursLoading extends WorkingHoursState {
  const WorkingHoursLoading();
}

/// The first load failed; there is no schedule to show.
final class WorkingHoursLoadFailure extends WorkingHoursState {
  final String message;

  const WorkingHoursLoadFailure(this.message);
}

/// A schedule is on screen, Sunday first. The subtypes describe the latest
/// save attempt.
sealed class WorkingHoursReady extends WorkingHoursState {
  final List<DaySchedule> days;

  const WorkingHoursReady(this.days);
}

final class WorkingHoursEditing extends WorkingHoursReady {
  const WorkingHoursEditing(super.days);
}

final class WorkingHoursSaving extends WorkingHoursReady {
  const WorkingHoursSaving(super.days);
}

/// Holds the schedule as the server saved it.
final class WorkingHoursSaved extends WorkingHoursReady {
  const WorkingHoursSaved(super.days);
}

/// Save failed; [days] keeps the unsaved edits so the merchant can retry.
final class WorkingHoursSaveFailure extends WorkingHoursReady {
  final String message;

  const WorkingHoursSaveFailure(super.days, this.message);
}
