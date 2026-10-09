import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/realtime/realtime_hub.dart';
import '../../domain/notification_failures.dart';
import '../../domain/repos/realtime_repository.dart';
import '../datasources/realtime_remote_data_source.dart';
import '../datasources/realtime_socket.dart';

class RealtimeRepositoryImpl implements RealtimeRepository {
  final RealtimeRemoteDataSource _remote;
  final RealtimeSocket _socket;
  final RealtimeHub _hub;
  final bool _isConfigured;

  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  int _subscriptionCount = 0;

  RealtimeRepositoryImpl({
    required RealtimeRemoteDataSource remote,
    required RealtimeSocket socket,
    required RealtimeHub hub,
    required bool isConfigured,
  }) : _remote = remote,
       _socket = socket,
       _hub = hub,
       _isConfigured = isConfigured;

  static String channelFor(int merchantId) => 'private-merchant.$merchantId';

  @override
  Future<Either<Failure, Unit>> connect() async {
    if (!_isConfigured) {
      return const Left<Failure, Unit>(RealtimeUnavailableFailure());
    }
    return guardFailure(() async {
      await disconnect();
      final int merchantId = await _remote.getMerchantId();

      _subscriptions
        ..add(
          _socket.messages.listen((RealtimeSocketMessage message) {
            final RealtimeEvent? event = RealtimeEvent.fromWire(
              message.name,
              message.data,
            );
            if (event != null) _hub.publish(event);
          }),
        )
        ..add(
          _socket.subscribed.listen((_) {
            // The first subscription follows the screens' own first load;
            // later ones follow a reconnect, after which events may have
            // been missed.
            if (_subscriptionCount++ > 0) _hub.publish(RealtimeEvent.resync);
          }),
        );

      await _socket.open(
        channelName: channelFor(merchantId),
        authorize: (String socketId, String channelName) => _remote
            .authorizeChannel(socketId: socketId, channelName: channelName),
      );
      return unit;
    });
  }

  @override
  Future<void> disconnect() async {
    for (final StreamSubscription<dynamic> subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _subscriptionCount = 0;
    await _socket.close();
  }
}
