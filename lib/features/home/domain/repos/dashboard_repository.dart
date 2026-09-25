import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';

/// The merchant's dashboard figures, computed by the server.
abstract class DashboardRepository {
  Future<Either<Failure, DashboardStats>> getDashboardStats();
}
