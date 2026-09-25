import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/day_schedule.dart';
import '../../domain/repos/working_hours_repository.dart';
import '../datasources/working_hours_remote_data_source.dart';

class WorkingHoursRepositoryImpl implements WorkingHoursRepository {
  final WorkingHoursRemoteDataSource _remote;

  const WorkingHoursRepositoryImpl({
    required WorkingHoursRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<Either<Failure, List<DaySchedule>>> getWorkingHours() =>
      guardFailure(_remote.getWorkingHours);

  @override
  Future<Either<Failure, List<DaySchedule>>> saveWorkingHours(
    List<DaySchedule> days,
  ) => guardFailure(() => _remote.saveWorkingHours(days));
}
