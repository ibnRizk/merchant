import '../../../../core/entities/merchant_approval_status.dart';
import '../../../../core/utils/json_values.dart';
import '../../domain/entities/onboarding_status.dart';

/// Parses `GET /vendor/onboarding-status`:
/// `{approval_status, can_operate, account_status, rejection_reason, ...}`.
class OnboardingStatusModel extends OnboardingStatus {
  const OnboardingStatusModel({required super.status, super.rejectionReason});

  factory OnboardingStatusModel.fromJson(Map<String, dynamic> json) {
    final String reason = (json['rejection_reason'] ?? '').toString().trim();
    return OnboardingStatusModel(
      status: _statusOf(json),
      rejectionReason: reason.isEmpty ? null : reason,
    );
  }

  /// `can_operate` is the authority. When it is false, an approval the
  /// server still reports means an admin blocked the account since; any
  /// unknown value counts as pending, so access is never granted by mistake.
  static MerchantApprovalStatus _statusOf(Map<String, dynamic> json) {
    if (isTruthy(json['can_operate'])) return MerchantApprovalStatus.approved;
    return switch (json['approval_status']?.toString()) {
      'rejected' || 'denied' => MerchantApprovalStatus.rejected,
      'approved' => MerchantApprovalStatus.suspended,
      _ => MerchantApprovalStatus.pending,
    };
  }
}
