import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/params/update_profile_params.dart';
import '../models/merchant_profile_model.dart';
import '../models/profile_requests.dart';

/// Talks to the token-protected `/vendor/profile`, `/vendor/logout` and
/// `/vendor/account` routes. Throws [AppException]s; the repository turns
/// them into failures.
abstract class ProfileRemoteDataSource {
  Future<MerchantProfileModel> getProfile();

  Future<MerchantProfileModel> updateProfile(UpdateProfileParams params);

  Future<void> logout();

  Future<void> requestAccountDeletion({String? reason});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioConsumer _client;

  const ProfileRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<MerchantProfileModel> getProfile() async {
    final dynamic response = await _client.get(ApiEndpoints.vendorProfile);
    return MerchantProfileModel.fromJson(_asMap(response));
  }

  @override
  Future<MerchantProfileModel> updateProfile(UpdateProfileParams params) async {
    final dynamic response = await _client.patch(
      ApiEndpoints.vendorProfile,
      body: params.toJson(),
    );
    return MerchantProfileModel.fromJson(_asMap(response));
  }

  @override
  Future<void> logout() => _client.post(ApiEndpoints.vendorLogout);

  /// Answers 202 `{status: "pending"}`; there is nothing else to read.
  @override
  Future<void> requestAccountDeletion({String? reason}) {
    final String? trimmed = reason?.trim();
    return _client.delete(
      ApiEndpoints.vendorAccount,
      data: (trimmed == null || trimmed.isEmpty)
          ? null
          : <String, dynamic>{'reason': trimmed},
    );
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw const ServerException(message: 'Unexpected response format.');
  }
}
