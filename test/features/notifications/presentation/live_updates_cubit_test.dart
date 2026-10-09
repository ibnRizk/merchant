import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/notifications/domain/notification_failures.dart';
import 'package:ssm_merchant/features/notifications/presentation/cubit/live_updates/live_updates_cubit.dart';

import '../notifications_fakes.dart';

void main() {
  late FakePushTokenRepository pushTokens;
  late FakeRealtimeRepository realtime;
  late LiveUpdatesCubit cubit;

  setUp(() {
    pushTokens = FakePushTokenRepository();
    realtime = FakeRealtimeRepository();
    cubit = LiveUpdatesCubit(pushTokens: pushTokens, realtime: realtime);
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  test('start registers the device and connects realtime', () async {
    await cubit.start();

    expect(pushTokens.registerDeviceCalls, 1);
    expect(realtime.connectCalls, 1);
    expect(cubit.state.pushRegistered, isTrue);
    expect(cubit.state.realtimeConnected, isTrue);
  });

  test('starting twice does not connect twice', () async {
    await cubit.start();
    await cubit.start();

    expect(realtime.connectCalls, 1);
    expect(pushTokens.registerDeviceCalls, 1);
  });

  test('missing config leaves both channels down without failing', () async {
    pushTokens.registerResult = const Left<Failure, Unit>(
      PushUnavailableFailure(),
    );
    realtime.connectResult = const Left<Failure, Unit>(
      RealtimeUnavailableFailure(),
    );

    await cubit.start();

    expect(cubit.state.started, isTrue);
    expect(cubit.state.pushRegistered, isFalse);
    expect(cubit.state.realtimeConnected, isFalse);
  });

  test('a rotated FCM token is sent to the server', () async {
    await cubit.start();

    pushTokens.refreshes.add('rotated-token');
    await pumpEventQueue();

    expect(pushTokens.registeredTokens, <String>['rotated-token']);
  });

  test('closing disconnects realtime and stops following tokens', () async {
    await cubit.start();

    await cubit.close();
    pushTokens.refreshes.add('late-token');
    await pumpEventQueue();

    expect(realtime.disconnectCalls, 1);
    expect(pushTokens.registeredTokens, isEmpty);
  });
}
