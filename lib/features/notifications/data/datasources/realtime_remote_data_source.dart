import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';

/// The two REST calls realtime needs. Both go through [DioConsumer], so the
/// merchant's bearer token and headers are attached as for any request.
abstract class RealtimeRemoteDataSource {
  /// `GET /vendor/session/validate` → `merchant.id`.
  Future<int> getMerchantId();

  /// `POST /broadcasting/auth` → the `auth` signature Pusher expects.
  Future<String> authorizeChannel({
    required String socketId,
    required String channelName,
  });
}

class RealtimeRemoteDataSourceImpl implements RealtimeRemoteDataSource {
  final DioConsumer _client;

  const RealtimeRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<int> getMerchantId() async {
    final dynamic response = await _client.get(ApiEndpoints.sessionValidate);
    final dynamic merchant = response is Map ? response['merchant'] : null;
    final int id = jsonInt(
      merchant is Map ? merchant['id'] : null,
      fallback: 0,
    );
    if (id <= 0) throw ServerException.unexpectedResponse();
    return id;
  }

  /// Laravel reads `socket_id` / `channel_name` from a JSON body as well as
  /// a form body, so the shared JSON client is used.
  @override
  Future<String> authorizeChannel({
    required String socketId,
    required String channelName,
  }) async {
    final dynamic response = await _client.post(
      ApiEndpoints.broadcastingAuth,
      body: <String, dynamic>{
        'socket_id': socketId,
        'channel_name': channelName,
      },
    );
    final String auth = response is Map ? jsonText(response['auth']) : '';
    if (auth.isEmpty) throw ServerException.unexpectedResponse();
    return auth;
  }
}
