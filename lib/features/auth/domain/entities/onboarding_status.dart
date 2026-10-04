import 'package:equatable/equatable.dart';

import '../../../../core/entities/merchant_approval_status.dart';

/// `GET /vendor/onboarding-status`: whether the account may operate yet.
class OnboardingStatus extends Equatable {
  /// Already folded with `can_operate`: [MerchantApprovalStatus.approved]
  /// only when the merchant can actually use operational routes.
  final MerchantApprovalStatus status;

  /// Set by an admin when the application was rejected.
  final String? rejectionReason;

  const OnboardingStatus({required this.status, this.rejectionReason});

  bool get canOperate => status == MerchantApprovalStatus.approved;

  @override
  List<Object?> get props => [status, rejectionReason];
}
