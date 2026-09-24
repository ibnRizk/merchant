import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/register_params.dart';
import '../../domain/params/reset_password_params.dart';
import '../../domain/params/verify_token_params.dart';
import '../models/auth_requests.dart';
import '../models/merchant_auth_result_model.dart';

/// Talks to the public `/auth/vendor/*` routes. Throws [AppException]s; the
/// repository turns them into failures.
abstract class MerchantAuthRemoteDataSource {
  Future<MerchantAuthResultModel> login(LoginParams params);

  /// Returns the new store's id.
  Future<int> register(RegisterParams params);

  Future<void> forgotPassword(String email);

  Future<void> verifyToken(VerifyTokenParams params);

  Future<void> resetPassword(ResetPasswordParams params);
}

class MerchantAuthRemoteDataSourceImpl implements MerchantAuthRemoteDataSource {
  final DioConsumer _client;

  const MerchantAuthRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<MerchantAuthResultModel> login(LoginParams params) async {
    final dynamic response = await _client.post(
      ApiEndpoints.login,
      body: params.toJson(),
    );
    return MerchantAuthResultModel.fromJson(_asMap(response));
  }

  @override
  Future<int> register(RegisterParams params) async {
    final dynamic response = await _client.post(
      ApiEndpoints.register,
      formData: await params.toFormData(),
    );
    final int? storeId = int.tryParse('${_asMap(response)['store_id']}');
    if (storeId == null) {
      throw const ServerException(
        message: 'Register response has no store_id.',
      );
    }
    return storeId;
  }

  @override
  Future<void> forgotPassword(String email) => _client.post(
    ApiEndpoints.forgotPassword,
    body: <String, dynamic>{'email': email.trim()},
  );

  @override
  Future<void> verifyToken(VerifyTokenParams params) =>
      _client.post(ApiEndpoints.verifyToken, body: params.toJson());

  @override
  Future<void> resetPassword(ResetPasswordParams params) =>
      _client.put(ApiEndpoints.resetPassword, body: params.toJson());

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw const ServerException(message: 'Unexpected response format.');
  }
}
