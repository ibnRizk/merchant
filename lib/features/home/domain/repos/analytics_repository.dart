import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/store_analytics.dart';

/// Store performance figures, computed by the server.
abstract class AnalyticsRepository {
  /// Both dates are inclusive days.
  Future<Either<Failure, StoreAnalytics>> getAnalytics({
    required DateTime from,
    required DateTime to,
  });
}
