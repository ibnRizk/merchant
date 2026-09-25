import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/day_schedule.dart';

/// The store's weekly opening hours.
abstract class WorkingHoursRepository {
  /// All seven days, Sunday first.
  Future<Either<Failure, List<DaySchedule>>> getWorkingHours();

  /// Replaces the whole week; returns the schedule as the server saved it.
  Future<Either<Failure, List<DaySchedule>>> saveWorkingHours(
    List<DaySchedule> days,
  );
}
