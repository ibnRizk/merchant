import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/utils/json_values.dart';

/// Talks to `POST /vendor/update-active-status`. Throws `AppException`s; the
/// repository turns them into failures.
abstract class StoreStatusRemoteDataSource {
  Future<bool> setStoreOpen({required bool isOpen});
}

class StoreStatusRemoteDataSourceImpl implements StoreStatusRemoteDataSource {
  final DioConsumer _client;

  const StoreStatusRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  /// Answers `{message, active}`; trusts the request when `active` is
  /// missing, since a 2xx means it was applied.
  @override
  Future<bool> setStoreOpen({required bool isOpen}) async {
    final dynamic response = await _client.post(
      ApiEndpoints.updateActiveStatus,
      body: <String, dynamic>{'is_open': isOpen},
    );
    if (response is Map && response.containsKey('active')) {
      return isTruthy(response['active']);
    }
    return isOpen;
  }
}
