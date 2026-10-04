import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/merchant_profile.dart';
import '../params/update_profile_params.dart';

abstract class ProfileRepository {
  Future<Either<Failure, MerchantProfile>> getProfile();

  /// Returns the profile as saved by the server.
  Future<Either<Failure, MerchantProfile>> updateProfile(
    UpdateProfileParams params,
  );

  /// Ends the session: revokes the token server-side (best effort) and always
  /// clears it locally.
  Future<Either<Failure, Unit>> logout();

  /// `DELETE /vendor/account`. Success (202) means the request is queued for
  /// an admin; the account still exists until then. Fails with
  /// [AccountDeletionBlockedFailure] while orders or wallet are open.
  Future<Either<Failure, Unit>> requestAccountDeletion({String? reason});
}
