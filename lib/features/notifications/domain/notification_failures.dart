import '../../../core/error/failures.dart';

/// The device has no push token: Firebase isn't configured, or iOS hasn't
/// issued an APNs token yet. Not an error the merchant can act on.
class PushUnavailableFailure extends Failure {
  @override
  final String? message;

  const PushUnavailableFailure({this.message});
}

/// Realtime is turned off (no Pusher key in `.env`). Screens still poll.
class RealtimeUnavailableFailure extends Failure {
  @override
  final String? message;

  const RealtimeUnavailableFailure({this.message});
}
