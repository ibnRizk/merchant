import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../models/dashboard_stats_model.dart';

/// Talks to `GET /vendor/dashboard-stats`. Throws `AppException`s; the
/// repository turns them into failures.
abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioConsumer _client;

  const DashboardRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    final dynamic response = await _client.get(ApiEndpoints.dashboardStats);
    if (response is! Map<String, dynamic>) {
      throw const ServerException(message: 'Unexpected response format.');
    }
    return DashboardStatsModel.fromJson(response);
  }
}
