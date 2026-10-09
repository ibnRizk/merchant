import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ssm_merchant/features/notifications/data/datasources/realtime_remote_data_source.dart';

import '../notifications_fakes.dart';

void main() {
  late FakeDioConsumer client;

  setUp(() => client = FakeDioConsumer());

  group('NotificationsRemoteDataSourceImpl', () {
    late NotificationsRemoteDataSourceImpl source;

    setUp(() => source = NotificationsRemoteDataSourceImpl(client: client));

    test('lists a page of 20', () async {
      client.response = <String, dynamic>{
        'data': <dynamic>[],
        'meta': <String, dynamic>{'current_page': 2, 'last_page': 2},
      };

      await source.getNotifications(page: 2);

      expect(client.calls.single.verb, 'GET');
      expect(client.calls.single.path, ApiEndpoints.notifications);
      expect(client.calls.single.query, <String, dynamic>{
        'page': 2,
        'per_page': 20,
      });
    });

    test('reads the unread count', () async {
      client.response = <String, dynamic>{'count': 4};

      expect(await source.getUnreadCount(), 4);
      expect(client.calls.single.path, '/vendor/notifications/unread-count');
    });

    test('an unread count without `count` is an unexpected response', () {
      client.response = <String, dynamic>{};

      expect(source.getUnreadCount(), throwsA(isA<ServerException>()));
    });

    test('marks one read with PATCH on its id', () async {
      await source.markAsRead('9b1d-uuid');

      expect(client.calls.single.verb, 'PATCH');
      expect(client.calls.single.path, '/vendor/notifications/9b1d-uuid/read');
    });

    test('marks all read with POST', () async {
      await source.markAllAsRead();

      expect(client.calls.single.verb, 'POST');
      expect(client.calls.single.path, '/vendor/notifications/read-all');
    });

    test('sends the FCM token as `fcm_token`', () async {
      await source.updateFcmToken('tok-1');

      expect(client.calls.single.path, '/vendor/update-fcm-token');
      expect(client.calls.single.body, <String, dynamic>{'fcm_token': 'tok-1'});
    });

    test('removes the FCM token', () async {
      await source.removeFcmToken();

      expect(client.calls.single.verb, 'POST');
      expect(client.calls.single.path, '/vendor/remove-fcm-token');
    });
  });

  group('RealtimeRemoteDataSourceImpl', () {
    late RealtimeRemoteDataSourceImpl source;

    setUp(() => source = RealtimeRemoteDataSourceImpl(client: client));

    test('reads merchant.id from session/validate', () async {
      client.response = <String, dynamic>{
        'authenticated': true,
        'merchant': <String, dynamic>{'id': 31},
      };

      expect(await source.getMerchantId(), 31);
      expect(client.calls.single.path, '/vendor/session/validate');
    });

    test('a session without a merchant id is an unexpected response', () {
      client.response = <String, dynamic>{'authenticated': true};

      expect(source.getMerchantId(), throwsA(isA<ServerException>()));
    });

    test('authorizes the channel with socket_id and channel_name', () async {
      client.response = <String, dynamic>{'auth': 'key:sig'};

      final String auth = await source.authorizeChannel(
        socketId: '123.456',
        channelName: 'private-merchant.31',
      );

      expect(auth, 'key:sig');
      expect(client.calls.single.verb, 'POST');
      expect(client.calls.single.path, '/broadcasting/auth');
      expect(client.calls.single.body, <String, dynamic>{
        'socket_id': '123.456',
        'channel_name': 'private-merchant.31',
      });
    });

    test('an authorization without `auth` is an unexpected response', () {
      client.response = <String, dynamic>{};

      expect(
        source.authorizeChannel(socketId: '1.2', channelName: 'c'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
