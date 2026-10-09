import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/log_utils.dart';
import '../../../domain/notification_failures.dart';
import '../../../domain/repos/push_token_repository.dart';
import '../../../domain/repos/realtime_repository.dart';
import 'live_updates_state.dart';

export 'live_updates_state.dart';

/// Owns the signed-in session's live channels: the FCM token on the server
/// and the realtime socket. Provided at the home route, so it starts when
/// the merchant reaches home and closes (disconnecting the socket) when
/// the session ends there: logout, a 401 or a suspension.
///
/// Logout removes the FCM token itself (`LogoutCubit`), because that has to
/// happen while the session token is still valid.
class LiveUpdatesCubit extends Cubit<LiveUpdatesState> {
  final PushTokenRepository _pushTokens;
  final RealtimeRepository _realtime;
  StreamSubscription<String>? _tokenRefreshes;

  LiveUpdatesCubit({
    required PushTokenRepository pushTokens,
    required RealtimeRepository realtime,
  }) : _pushTokens = pushTokens,
       _realtime = realtime,
       super(const LiveUpdatesState());

  Future<void> start() async {
    if (state.started) return;
    emit(state.copyWith(started: true));

    _tokenRefreshes = _pushTokens.tokenRefreshes.listen(
      (String token) async =>
          _report('FCM token refresh', await _pushTokens.registerToken(token)),
    );

    final (Either<Failure, Unit> push, Either<Failure, Unit> realtime) = await (
      _pushTokens.registerDevice(),
      _realtime.connect(),
    ).wait;
    if (isClosed) return;

    _report('FCM token registration', push);
    _report('Realtime connection', realtime);
    emit(
      state.copyWith(
        pushRegistered: push.isRight(),
        realtimeConnected: realtime.isRight(),
      ),
    );
  }

  /// Neither channel is essential (screens still poll), so failures are
  /// logged, not shown. "Not configured" is expected until the config lands.
  void _report(String what, Either<Failure, Unit> result) =>
      result.fold((Failure failure) {
        if (failure is PushUnavailableFailure ||
            failure is RealtimeUnavailableFailure) {
          Log.i('$what skipped: not configured on this build/device');
        } else {
          Log.w('$what failed: ${failure.message}');
        }
      }, (_) {});

  @override
  Future<void> close() async {
    await _tokenRefreshes?.cancel();
    await _realtime.disconnect();
    return super.close();
  }
}
