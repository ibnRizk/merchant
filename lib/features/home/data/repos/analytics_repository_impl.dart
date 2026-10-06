import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/store_analytics.dart';
import '../../domain/repos/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;

  const AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, StoreAnalytics>> getAnalytics({
    required DateTime from,
    required DateTime to,
  }) => guardFailure<StoreAnalytics>(
    () => _remote.getAnalytics(from: from, to: to),
  );
}
