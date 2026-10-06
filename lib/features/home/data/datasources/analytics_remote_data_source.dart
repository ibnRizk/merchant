import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';
import '../models/store_analytics_model.dart';

/// Talks to `GET /vendor/analytics`. Throws [AppException]s; the
/// repository turns them into failures.
abstract class AnalyticsRemoteDataSource {
  Future<StoreAnalyticsModel> getAnalytics({
    required DateTime from,
    required DateTime to,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final DioConsumer _client;

  const AnalyticsRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<StoreAnalyticsModel> getAnalytics({
    required DateTime from,
    required DateTime to,
  }) async {
    final dynamic response = await _client.get(
      ApiEndpoints.analytics,
      queryParameters: <String, dynamic>{
        'from': jsonDate(from),
        'to': jsonDate(to),
      },
    );
    if (response is! Map<String, dynamic>) {
      throw ServerException.unexpectedResponse();
    }
    return StoreAnalyticsModel.fromJson(response);
  }
}
