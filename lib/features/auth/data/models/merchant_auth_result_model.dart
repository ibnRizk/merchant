import '../../../../core/error/exceptions.dart';
import '../../domain/entities/merchant_auth_result.dart';

/// Response of `POST /auth/vendor/login`:
/// `{token, zone_wise_topic, module_type}`, plus `approval_status` for
/// accounts that are not approved yet.
class MerchantAuthResultModel extends MerchantAuthResult {
  const MerchantAuthResultModel({
    required super.token,
    required super.approvalStatus,
    super.zoneWiseTopic,
    super.moduleType,
  });

  factory MerchantAuthResultModel.fromJson(Map<String, dynamic> json) {
    final Object? token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const ServerException(message: 'Login response has no token.');
    }
    return MerchantAuthResultModel(
      token: token,
      approvalStatus: _approvalStatusFrom(json['approval_status']),
      zoneWiseTopic: json['zone_wise_topic']?.toString(),
      moduleType: json['module_type']?.toString(),
    );
  }

  /// Approved accounts get no `approval_status` at all. An unrecognised value
  /// is treated as pending so the app never grants operational access by
  /// mistake.
  static MerchantApprovalStatus _approvalStatusFrom(Object? raw) {
    return switch (raw) {
      null || 'approved' => MerchantApprovalStatus.approved,
      'rejected' || 'denied' => MerchantApprovalStatus.rejected,
      'suspended' => MerchantApprovalStatus.suspended,
      _ => MerchantApprovalStatus.pending,
    };
  }
}
