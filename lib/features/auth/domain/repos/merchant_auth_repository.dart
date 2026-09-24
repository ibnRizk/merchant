import 'package:dartz/dartz.dart';

import '../../../../core/entities/store_category.dart';
import '../../../../core/error/failures.dart';
import '../entities/merchant_auth_result.dart';
import '../params/login_params.dart';
import '../params/register_params.dart';
import '../params/reset_password_params.dart';
import '../params/verify_token_params.dart';

/// Merchant authentication and password recovery. All endpoints are public
/// (no bearer token) and throttled to 10 requests per minute per IP.
abstract class MerchantAuthRepository {
  /// `POST /auth/vendor/login`. Pending accounts still get a token.
  Future<Either<Failure, MerchantAuthResult>> login(LoginParams params);

  /// `GET /auth/vendor/store-categories`. Active categories in display
  /// order; an empty list is valid.
  Future<Either<Failure, List<StoreCategory>>> getStoreCategories();

  /// `POST /auth/vendor/register`. Returns the new store's id.
  Future<Either<Failure, int>> register(RegisterParams params);

  /// `POST /auth/vendor/forgot-password`. E-mails a reset OTP to [email].
  Future<Either<Failure, Unit>> forgotPassword(String email);

  /// `POST /auth/vendor/verify-token`. Checks the reset OTP.
  Future<Either<Failure, Unit>> verifyToken(VerifyTokenParams params);

  /// `PUT /auth/vendor/reset-password`. Sets the new password.
  Future<Either<Failure, Unit>> resetPassword(ResetPasswordParams params);
}
