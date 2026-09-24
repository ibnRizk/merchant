import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/local_storage/app_secure_storage.dart';
import '../../domain/entities/merchant_auth_result.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/register_params.dart';
import '../../domain/params/reset_password_params.dart';
import '../../domain/params/verify_token_params.dart';
import '../../domain/repos/merchant_auth_repository.dart';
import '../datasources/merchant_auth_remote_data_source.dart';

class MerchantAuthRepositoryImpl implements MerchantAuthRepository {
  final MerchantAuthRemoteDataSource _remote;
  final AppSecureStorage _secureStorage;

  const MerchantAuthRepositoryImpl({
    required MerchantAuthRemoteDataSource remote,
    required AppSecureStorage secureStorage,
  }) : _remote = remote,
       _secureStorage = secureStorage;

  @override
  Future<Either<Failure, MerchantAuthResult>> login(LoginParams params) {
    return _guard(() async {
      final MerchantAuthResult result = await _remote.login(params);
      // Saved for pending accounts too: they still need it for onboarding
      // routes. DioConsumer attaches it to every later request.
      await _secureStorage.saveAccessToken(result.token);
      return result;
    });
  }

  @override
  Future<Either<Failure, int>> register(RegisterParams params) =>
      _guard(() => _remote.register(params));

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) =>
      _guard(() async {
        await _remote.forgotPassword(email);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> verifyToken(VerifyTokenParams params) =>
      _guard(() async {
        await _remote.verifyToken(params);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> resetPassword(ResetPasswordParams params) =>
      _guard(() async {
        await _remote.resetPassword(params);
        return unit;
      });

  /// Single boundary where exceptions become failures.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right<Failure, T>(await action());
    } on AppException catch (e) {
      return Left<Failure, T>(e.toFailure());
    } on FileSystemException {
      // A picked image was deleted or moved before upload.
      return Left<Failure, T>(const FetchDataFailure());
    } catch (_) {
      // No message: raw exception text is not fit to show users.
      return Left<Failure, T>(const ServerFailure());
    }
  }
}
