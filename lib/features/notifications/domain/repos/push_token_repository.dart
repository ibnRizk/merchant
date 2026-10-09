import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Keeps the backend's copy of this device's FCM token in sync with the
/// session.
abstract class PushTokenRepository {
  /// Asks for notification permission, then sends the device token
  /// (`POST /vendor/update-fcm-token`). Fails with `PushUnavailableFailure`
  /// when there is no token.
  Future<Either<Failure, Unit>> registerDevice();

  /// Sends a token FCM rotated (see [tokenRefreshes]).
  Future<Either<Failure, Unit>> registerToken(String token);

  /// New tokens FCM issues while the app runs.
  Stream<String> get tokenRefreshes;

  /// Call before logout, while the session token still works: asks the
  /// server to forget the device (`POST /vendor/remove-fcm-token`), then
  /// invalidates the token locally. Both steps are best effort; it never
  /// blocks a logout.
  Future<Either<Failure, Unit>> unregisterDevice();
}
