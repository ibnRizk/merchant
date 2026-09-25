import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/entities/store_category.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/services/local_storage/app_secure_storage.dart';
import 'package:ssm_merchant/features/profile/domain/entities/merchant_profile.dart';
import 'package:ssm_merchant/features/profile/domain/params/update_profile_params.dart';
import 'package:ssm_merchant/features/profile/domain/repos/profile_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

export '../../helpers/fake_dio_consumer.dart';

const MerchantProfile sampleProfile = MerchantProfile(
  id: 7,
  firstName: 'Sara',
  lastName: 'Ali',
  email: 'sara@example.com',
  phone: '+201000000000',
  store: StoreProfile(
    id: 42,
    name: 'Mazaq',
    phone: '+201111111111',
    email: 'store@example.com',
    address: 'Tahrir St',
    category: StoreCategory(
      id: 3,
      name: 'Restaurant',
      nameAr: 'مطعم',
      nameEn: 'Restaurant',
    ),
  ),
);

/// In-memory token store; never touches the platform channel.
class FakeSecureStorage extends AppSecureStorage {
  FakeSecureStorage({this.accessToken})
    : super(instance: const FlutterSecureStorage());

  String? accessToken;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<void> saveAccessToken(String? token) async => accessToken = token;

  @override
  Future<void> removeAccessToken() async => accessToken = null;

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Future<void> saveDeviceToken(String token) async {}

  @override
  Future<void> removeDeviceToken() async {}

  @override
  Future<void> clearAll() async => accessToken = null;
}

class FakeProfileRepository implements ProfileRepository {
  Either<Failure, MerchantProfile> getResult = const Right(sampleProfile);
  Either<Failure, MerchantProfile> updateResult = const Right(sampleProfile);
  Either<Failure, Unit> logoutResult = const Right(unit);

  final List<UpdateProfileParams> updateCalls = <UpdateProfileParams>[];
  int logoutCalls = 0;

  @override
  Future<Either<Failure, MerchantProfile>> getProfile() async => getResult;

  @override
  Future<Either<Failure, MerchantProfile>> updateProfile(
    UpdateProfileParams params,
  ) async {
    updateCalls.add(params);
    return updateResult;
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return logoutResult;
  }
}
