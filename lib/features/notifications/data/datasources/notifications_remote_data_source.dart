import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';
import '../models/notification_models.dart';

/// Inbox and FCM-token routes. Throws [AppException]s; the repositories
/// turn them into failures.
abstract class NotificationsRemoteDataSource {
  static const int pageSize = 20;

  Future<NotificationsPageModel> getNotifications({required int page});

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> updateFcmToken(String token);

  Future<void> removeFcmToken();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final DioConsumer _client;

  const NotificationsRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<NotificationsPageModel> getNotifications({required int page}) async {
    final dynamic response = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': NotificationsRemoteDataSource.pageSize,
      },
    );
    return NotificationsPageModel.fromJson(_asMap(response));
  }

  @override
  Future<int> getUnreadCount() async {
    final Map<String, dynamic> json = _asMap(
      await _client.get(ApiEndpoints.notificationsUnreadCount),
    );
    final int count = jsonInt(json['count'], fallback: -1);
    if (count < 0) throw ServerException.unexpectedResponse();
    return count;
  }

  @override
  Future<void> markAsRead(String id) =>
      _client.patch(ApiEndpoints.notificationRead(Uri.encodeComponent(id)));

  @override
  Future<void> markAllAsRead() =>
      _client.post(ApiEndpoints.notificationsReadAll);

  @override
  Future<void> updateFcmToken(String token) => _client.post(
    ApiEndpoints.updateFcmToken,
    body: <String, dynamic>{'fcm_token': token},
  );

  @override
  Future<void> removeFcmToken() => _client.post(ApiEndpoints.removeFcmToken);

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw ServerException.unexpectedResponse();
  }
}
