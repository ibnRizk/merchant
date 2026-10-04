import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/entities/store_category.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/auth/domain/entities/merchant_auth_result.dart';
import 'package:ssm_merchant/features/auth/domain/entities/onboarding_status.dart';
import 'package:ssm_merchant/features/auth/domain/params/login_params.dart';
import 'package:ssm_merchant/features/auth/domain/params/register_params.dart';
import 'package:ssm_merchant/features/auth/domain/params/reset_password_params.dart';
import 'package:ssm_merchant/features/auth/domain/params/verify_token_params.dart';
import 'package:ssm_merchant/features/auth/domain/repos/merchant_auth_repository.dart';

export '../../helpers/fake_dio_consumer.dart';

const StoreCategory restaurant = StoreCategory(
  id: 3,
  name: 'Restaurant',
  nameAr: 'مطعم',
  nameEn: 'Restaurant',
);

RegisterParams registerParams({
  required String logoPath,
  int? storeCategoryId = 3,
}) => RegisterParams(
  fName: 'Sara',
  lName: 'Ali',
  email: 'sara@example.com',
  phone: '+201000000000',
  password: 'Strong#123',
  latitude: 31.03,
  longitude: 31.385,
  storeCategoryId: storeCategoryId,
  minimumDeliveryTime: 20,
  maximumDeliveryTime: 40,
  deliveryTimeType: DeliveryTimeType.min,
  translations: const <StoreTranslation>[
    StoreTranslation(locale: 'en', name: 'Mazaq', address: 'Tahrir St'),
  ],
  logoPath: logoPath,
);

/// A real file for `MultipartFile.fromFile`; deleted with its directory.
Future<String> createTempLogo() async {
  final Directory dir = await Directory.systemTemp.createTemp('ssm_logo');
  final File file = File('${dir.path}${Platform.pathSeparator}logo.png');
  await file.writeAsBytes(<int>[0]);
  return file.path;
}

class FakeMerchantAuthRepository implements MerchantAuthRepository {
  Either<Failure, List<StoreCategory>> categoriesResult =
      const Right<Failure, List<StoreCategory>>(<StoreCategory>[restaurant]);
  Either<Failure, OnboardingStatus> onboardingResult =
      const Right<Failure, OnboardingStatus>(
        OnboardingStatus(status: MerchantApprovalStatus.approved),
      );
  Either<Failure, Unit> clearSessionResult = const Right<Failure, Unit>(unit);
  Either<Failure, Unit> forgotPasswordResult = const Right<Failure, Unit>(
    unit,
  );
  Either<Failure, Unit> verifyTokenResult = const Right<Failure, Unit>(unit);
  Either<Failure, Unit> resetPasswordResult = const Right<Failure, Unit>(unit);

  int onboardingCalls = 0;
  int clearSessionCalls = 0;
  final List<String> forgotPasswordEmails = <String>[];
  final List<VerifyTokenParams> verifyCalls = <VerifyTokenParams>[];
  final List<ResetPasswordParams> resetCalls = <ResetPasswordParams>[];

  @override
  Future<Either<Failure, OnboardingStatus>> getOnboardingStatus() async {
    onboardingCalls++;
    return onboardingResult;
  }

  @override
  Future<Either<Failure, Unit>> clearSession() async {
    clearSessionCalls++;
    return clearSessionResult;
  }

  @override
  Future<Either<Failure, List<StoreCategory>>> getStoreCategories() async =>
      categoriesResult;

  @override
  Future<Either<Failure, MerchantAuthResult>> login(LoginParams params) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, int>> register(RegisterParams params) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    forgotPasswordEmails.add(email);
    return forgotPasswordResult;
  }

  @override
  Future<Either<Failure, Unit>> verifyToken(VerifyTokenParams params) async {
    verifyCalls.add(params);
    return verifyTokenResult;
  }

  @override
  Future<Either<Failure, Unit>> resetPassword(
    ResetPasswordParams params,
  ) async {
    resetCalls.add(params);
    return resetPasswordResult;
  }
}
