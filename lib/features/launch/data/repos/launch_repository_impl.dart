import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/local_storage/app_secure_storage.dart';
import '../../../../core/services/local_storage/app_shared_preferences.dart';
import '../../domain/repos/launch_repository.dart';

class LaunchRepositoryImpl implements LaunchRepository {
  final AppSharedPreferences _preferences;
  final AppSecureStorage _secureStorage;

  const LaunchRepositoryImpl({
    required AppSharedPreferences preferences,
    required AppSecureStorage secureStorage,
  }) : _preferences = preferences,
       _secureStorage = secureStorage;

  @override
  Future<Either<Failure, bool>> hasSession() => _guard(() async {
    final String? token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  });

  @override
  Future<Either<Failure, bool>> hasSeenOnboarding() =>
      _guard(() async => _preferences.getOnboardingSeen());

  @override
  Future<Either<Failure, Unit>> markOnboardingSeen() => _guard(() async {
    await _preferences.saveOnboardingSeen();
    return unit;
  });

  /// Keystore / platform-channel errors become a [CacheFailure].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right<Failure, T>(await action());
    } catch (_) {
      return const Left(CacheFailure());
    }
  }
}
