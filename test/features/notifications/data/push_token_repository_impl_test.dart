import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:ssm_merchant/features/notifications/data/repos/push_token_repository_impl.dart';
import 'package:ssm_merchant/features/notifications/domain/notification_failures.dart';

import '../notifications_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late FakePushTokenProvider device;
  late PushTokenRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer();
    device = FakePushTokenProvider();
    repository = PushTokenRepositoryImpl(
      remote: NotificationsRemoteDataSourceImpl(client: client),
      device: device,
    );
  });

  group('registerDevice', () {
    test('asks for permission, then sends the device token', () async {
      final Either<Failure, Unit> result = await repository.registerDevice();

      expect(result.isRight(), isTrue);
      expect(device.calls, <String>['requestPermission', 'getToken']);
      expect(client.calls.single.path, '/vendor/update-fcm-token');
      expect(client.calls.single.body, <String, dynamic>{
        'fcm_token': 'device-token',
      });
    });

    test('without a token fails as unavailable and calls nothing', () async {
      device.token = null;

      final Either<Failure, Unit> result = await repository.registerDevice();

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<PushUnavailableFailure>(),
      );
      expect(client.calls, isEmpty);
    });

    test('a server error comes back as a failure', () async {
      client.error = const ServerException(message: 'boom', statusCode: 500);

      final Either<Failure, Unit> result = await repository.registerDevice();

      expect(result.fold((Failure f) => f, (_) => null), isA<ServerFailure>());
    });
  });

  group('unregisterDevice', () {
    test('tells the server, then deletes the local token', () async {
      final Either<Failure, Unit> result = await repository.unregisterDevice();

      expect(result.isRight(), isTrue);
      expect(client.calls.single.path, '/vendor/remove-fcm-token');
      expect(device.deleteCalls, 1);
    });

    test(
      'still deletes the local token when the server is unreachable',
      () async {
        client.error = const InternetConnectionException(message: 'offline');

        final Either<Failure, Unit> result = await repository
            .unregisterDevice();

        expect(result.isRight(), isTrue);
        expect(device.deleteCalls, 1);
      },
    );
  });
}
