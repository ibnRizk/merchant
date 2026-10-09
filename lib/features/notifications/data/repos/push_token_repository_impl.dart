import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../../../core/services/push/push_notification_service.dart';
import '../../../../core/utils/log_utils.dart';
import '../../domain/notification_failures.dart';
import '../../domain/repos/push_token_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class PushTokenRepositoryImpl implements PushTokenRepository {
  final NotificationsRemoteDataSource _remote;
  final PushTokenProvider _device;

  const PushTokenRepositoryImpl({
    required NotificationsRemoteDataSource remote,
    required PushTokenProvider device,
  }) : _remote = remote,
       _device = device;

  @override
  Future<Either<Failure, Unit>> registerDevice() async {
    final Either<Failure, String?> token = await guardFailure(() async {
      await _device.requestPermission();
      return _device.getToken();
    });
    return token.fold(Left.new, (String? value) {
      if (value == null || value.isEmpty) {
        return const Left<Failure, Unit>(PushUnavailableFailure());
      }
      return registerToken(value);
    });
  }

  @override
  Future<Either<Failure, Unit>> registerToken(String token) =>
      guardFailure(() async {
        await _remote.updateFcmToken(token);
        return unit;
      });

  @override
  Stream<String> get tokenRefreshes => _device.onTokenRefresh;

  @override
  Future<Either<Failure, Unit>> unregisterDevice() => guardFailure(() async {
    try {
      await _remote.removeFcmToken();
    } on AppException catch (error) {
      // Offline or already signed out: deleting the token below still stops
      // pushes to this device.
      Log.w('remove-fcm-token failed: $error');
    }
    try {
      await _device.deleteToken();
    } catch (error) {
      Log.w('Deleting the FCM token failed: $error');
    }
    return unit;
  });
}
