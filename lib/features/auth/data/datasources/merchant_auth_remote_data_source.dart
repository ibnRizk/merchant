import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/store_category_model.dart';
import '../../../../core/utils/log_utils.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/register_params.dart';
import '../../domain/params/reset_password_params.dart';
import '../../domain/params/verify_token_params.dart';
import '../models/auth_requests.dart';
import '../models/merchant_auth_result_model.dart';
import '../models/onboarding_status_model.dart';

/// Talks to the public `/auth/vendor/*` routes and the onboarding status.
/// Throws [AppException]s; the repository turns them into failures.
abstract class MerchantAuthRemoteDataSource {
  Future<MerchantAuthResultModel> login(LoginParams params);

  Future<List<StoreCategoryModel>> getStoreCategories();

  /// Returns the new store's id.
  Future<int> register(RegisterParams params);

  Future<void> forgotPassword(String email);

  Future<void> verifyToken(VerifyTokenParams params);

  Future<void> resetPassword(ResetPasswordParams params);

  /// Needs the token; works while the account is pending.
  Future<OnboardingStatusModel> getOnboardingStatus();
}

class MerchantAuthRemoteDataSourceImpl implements MerchantAuthRemoteDataSource {
  final DioConsumer _client;

  /// Every new store registers into this zone and module. There is no API
  /// to list them, so they come from `.env` (`DEFAULT_ZONE_ID`,
  /// `DEFAULT_MODULE_ID`).
  final int? _zoneId;
  final int? _moduleId;

  const MerchantAuthRemoteDataSourceImpl({
    required DioConsumer client,
    required int? zoneId,
    required int? moduleId,
  }) : _client = client,
       _zoneId = zoneId,
       _moduleId = moduleId;

  @override
  Future<MerchantAuthResultModel> login(LoginParams params) async {
    final dynamic response = await _client.post(
      ApiEndpoints.login,
      body: params.toJson(),
    );
    return MerchantAuthResultModel.fromJson(_asMap(response));
  }

  @override
  Future<List<StoreCategoryModel>> getStoreCategories() async {
    final dynamic categories = _asMap(
      await _client.get(ApiEndpoints.storeCategories),
    )['categories'];
    if (categories is! List) {
      throw const ServerException(message: 'Categories response has no list.');
    }
    return <StoreCategoryModel>[
      for (final dynamic json in categories)
        if (StoreCategoryModel.tryParse(json) case final StoreCategoryModel c)
          c,
    ];
  }

  @override
  Future<int> register(RegisterParams params) async {
    final int? zoneId = _zoneId;
    final int? moduleId = _moduleId;
    if (zoneId == null || moduleId == null) {
      // A build misconfiguration, not something the merchant can fix: log the
      // cause, show the generic error.
      Log.e('Registration needs DEFAULT_ZONE_ID and DEFAULT_MODULE_ID in .env');
      throw const ServerException();
    }
    final dynamic response = await _client.post(
      ApiEndpoints.register,
      formData: await params.toFormData(zoneId: zoneId, moduleId: moduleId),
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

  @override
  Future<OnboardingStatusModel> getOnboardingStatus() async =>
      OnboardingStatusModel.fromJson(
        _asMap(await _client.get(ApiEndpoints.onboardingStatus)),
      );

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    throw const ServerException(message: 'Unexpected response format.');
  }
}
