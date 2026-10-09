import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// The merchant's private realtime channel (`private-merchant.{id}`).
/// Events are published to the app's `RealtimeHub`.
abstract class RealtimeRepository {
  /// Resolves the merchant id, connects and subscribes. The socket then
  /// reconnects by itself. Fails with `RealtimeUnavailableFailure` when no
  /// Pusher key is configured.
  Future<Either<Failure, Unit>> connect();

  Future<void> disconnect();
}
