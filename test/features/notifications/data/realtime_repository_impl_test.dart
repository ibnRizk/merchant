import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/realtime/realtime_event.dart';
import 'package:ssm_merchant/core/realtime/realtime_hub.dart';
import 'package:ssm_merchant/features/notifications/data/datasources/realtime_socket.dart';
import 'package:ssm_merchant/features/notifications/data/repos/realtime_repository_impl.dart';
import 'package:ssm_merchant/features/notifications/domain/notification_failures.dart';

import '../notifications_fakes.dart';

void main() {
  late FakeRealtimeRemoteDataSource remote;
  late FakeRealtimeSocket socket;
  late RealtimeHub hub;
  late List<RealtimeEvent> published;
  late StreamSubscription<RealtimeEvent> hubSubscription;

  RealtimeRepositoryImpl repository({bool isConfigured = true}) =>
      RealtimeRepositoryImpl(
        remote: remote,
        socket: socket,
        hub: hub,
        isConfigured: isConfigured,
      );

  setUp(() {
    remote = FakeRealtimeRemoteDataSource();
    socket = FakeRealtimeSocket();
    hub = RealtimeHub();
    published = <RealtimeEvent>[];
    hubSubscription = hub.events.listen(published.add);
  });

  tearDown(() => hubSubscription.cancel());

  test(
    'without a Pusher key it fails as unavailable and opens nothing',
    () async {
      final Either<Failure, Unit> result = await repository(
        isConfigured: false,
      ).connect();

      expect(
        result.fold((Failure f) => f, (_) => null),
        isA<RealtimeUnavailableFailure>(),
      );
      expect(socket.openedChannel, isNull);
    },
  );

  test("subscribes to the merchant's private channel", () async {
    final Either<Failure, Unit> result = await repository().connect();

    expect(result.isRight(), isTrue);
    expect(socket.openedChannel, 'private-merchant.77');
  });

  test('signs subscriptions through /broadcasting/auth', () async {
    await repository().connect();

    final String auth = await socket.authorizer!(
      '123.456',
      'private-merchant.77',
    );

    expect(auth, 'key:signature');
    expect(remote.authorizations.single, (
      socketId: '123.456',
      channelName: 'private-merchant.77',
    ));
  });

  test('a failed merchant lookup is a failure, not a crash', () async {
    remote.error = const UnauthorizedException(message: 'expired');

    final Either<Failure, Unit> result = await repository().connect();

    expect(
      result.fold((Failure f) => f, (_) => null),
      isA<UnauthorizedFailure>(),
    );
    expect(socket.openedChannel, isNull);
  });

  test('publishes known events and drops the rest', () async {
    await repository().connect();

    socket.messageController
      ..add(
        const RealtimeSocketMessage('ssm.order.created', <String, dynamic>{
          'order_id': 5,
        }),
      )
      ..add(const RealtimeSocketMessage('pusher:pong', null))
      ..add(const RealtimeSocketMessage('.ssm.notification.created', null));
    await pumpEventQueue();

    expect(published, const <RealtimeEvent>[
      RealtimeEvent(RealtimeEventType.orderCreated, orderId: 5),
      RealtimeEvent(RealtimeEventType.notificationCreated),
    ]);
  });

  test('resyncs after a re-subscription, not after the first one', () async {
    await repository().connect();

    socket.subscribedController.add(null);
    await pumpEventQueue();
    expect(published, isEmpty);

    socket.subscribedController.add(null);
    await pumpEventQueue();
    expect(published, const <RealtimeEvent>[RealtimeEvent.resync]);
  });

  test('disconnect closes the socket and stops publishing', () async {
    final RealtimeRepositoryImpl repo = repository();
    await repo.connect();
    final int closesBefore = socket.closeCalls;

    await repo.disconnect();
    socket.messageController.add(
      const RealtimeSocketMessage('ssm.order.created', null),
    );
    await pumpEventQueue();

    expect(socket.closeCalls, closesBefore + 1);
    expect(published, isEmpty);
  });
}
