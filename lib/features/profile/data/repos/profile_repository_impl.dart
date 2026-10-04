import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../../../core/services/local_storage/app_secure_storage.dart';
import '../../domain/entities/account_deletion.dart';
import '../../domain/entities/merchant_profile.dart';
import '../../domain/params/update_profile_params.dart';
import '../../domain/repos/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final AppSecureStorage _secureStorage;

  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required AppSecureStorage secureStorage,
  }) : _remote = remote,
       _secureStorage = secureStorage;

  @override
  Future<Either<Failure, MerchantProfile>> getProfile() =>
      guardFailure(_remote.getProfile);

  @override
  Future<Either<Failure, MerchantProfile>> updateProfile(
    UpdateProfileParams params,
  ) => guardFailure(() => _remote.updateProfile(params));

  @override
  Future<Either<Failure, Unit>> logout() => guardFailure(() async {
    try {
      await _remote.logout();
    } on AppException {
      // Revoking server-side is best effort: an offline device or an already
      // expired token must still be able to sign out locally.
    } finally {
      await _secureStorage.removeAccessToken();
    }
    return unit;
  });

  @override
  Future<Either<Failure, Unit>> requestAccountDeletion({
    String? reason,
  }) async {
    final Either<Failure, Unit> result = await guardFailure(() async {
      await _remote.requestAccountDeletion(reason: reason);
      return unit;
    });
    return result.leftMap(_deletionFailure);
  }

  /// Turns the documented 409 codes into a reason the UI can explain.
  static Failure _deletionFailure(Failure failure) {
    if (failure is! ConflictFailure) return failure;
    final DeletionBlockReason? reason = switch (failure.code) {
      'active_orders_exist' => DeletionBlockReason.activeOrders,
      'wallet_balance_not_settled' => DeletionBlockReason.walletNotSettled,
      _ => null,
    };
    return reason == null
        ? failure
        : AccountDeletionBlockedFailure(
            reason: reason,
            message: failure.message,
          );
  }
}
