import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

/// Local launch state: whether onboarding was shown and whether a session
/// token is saved. No network calls.
abstract class LaunchRepository {
  /// True when a non-empty access token is saved.
  Future<Either<Failure, bool>> hasSession();

  Future<Either<Failure, bool>> hasSeenOnboarding();

  /// Remembers that onboarding was shown so it is skipped next launch.
  Future<Either<Failure, Unit>> markOnboardingSeen();
}
