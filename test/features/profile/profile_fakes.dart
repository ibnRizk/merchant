import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_base/core/api/dio_consumer.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/core/services/local_storage/app_secure_storage.dart';
import 'package:flutter_base/features/profile/domain/entities/merchant_profile.dart';
import 'package:flutter_base/features/profile/domain/params/update_profile_params.dart';
import 'package:flutter_base/features/profile/domain/repos/profile_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  ),
);

/// Records calls and answers with canned responses or errors.
class FakeDioConsumer implements DioConsumer {
  dynamic response;
  Object? error;
  final List<({String verb, String path, Map<String, dynamic>? body})> calls =
      [];

  Future<dynamic> _answer(
    String verb,
    String path,
    Map<String, dynamic>? body,
  ) async {
    calls.add((verb: verb, path: path, body: body));
    if (error != null) throw error!;
    return response;
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _answer('GET', path, null);

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _answer('POST', path, body);

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _answer('PUT', path, body);

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) => _answer('PATCH', path, body);

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) => _answer('DELETE', path, null);

  @override
  void updateLanguageCodeHeader() {}

  @override
  void updateDeviceTokenHeader(String token) {}

  @override
  void updateDeviceTypeHeader() {}
}

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
