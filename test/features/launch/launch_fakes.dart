import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/launch/domain/repos/launch_repository.dart';

import '../profile/profile_fakes.dart';

export '../profile/profile_fakes.dart' show FakeSecureStorage;

class FakeLaunchRepository implements LaunchRepository {
  Either<Failure, bool> sessionResult = const Right(false);
  Either<Failure, bool> seenResult = const Right(false);
  Either<Failure, Unit> markSeenResult = const Right(unit);

  int markSeenCalls = 0;

  @override
  Future<Either<Failure, bool>> hasSession() async => sessionResult;

  @override
  Future<Either<Failure, bool>> hasSeenOnboarding() async => seenResult;

  @override
  Future<Either<Failure, Unit>> markOnboardingSeen() async {
    markSeenCalls++;
    return markSeenResult;
  }
}

/// Simulates a keystore failure when reading the token.
class ThrowingSecureStorage extends FakeSecureStorage {
  @override
  Future<String?> getAccessToken() async => throw Exception('keystore');
}
