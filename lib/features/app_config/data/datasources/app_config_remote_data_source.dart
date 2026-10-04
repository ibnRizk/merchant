import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';

/// Talks to `GET /vendor/config`. Throws [AppException]s; the repository
/// turns them into failures.
abstract class AppConfigRemoteDataSource {
  /// The raw body, so the repository can cache exactly what the server sent.
  Future<Map<String, dynamic>> getConfig();
}

class AppConfigRemoteDataSourceImpl implements AppConfigRemoteDataSource {
  final DioConsumer _client;

  const AppConfigRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<Map<String, dynamic>> getConfig() async {
    final dynamic response = await _client.get(ApiEndpoints.vendorConfig);
    if (response is Map<String, dynamic>) return response;
    throw const ServerException(message: 'Unexpected response format.');
  }
}
