import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repos/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remote;

  const DashboardRepositoryImpl({required DashboardRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() =>
      guardFailure<DashboardStats>(_remote.getDashboardStats);
}
