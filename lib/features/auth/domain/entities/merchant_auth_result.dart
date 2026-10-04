import 'package:equatable/equatable.dart';

import '../../../../core/entities/merchant_approval_status.dart';

export '../../../../core/entities/merchant_approval_status.dart';

/// Result of `POST /auth/vendor/login`.
class MerchantAuthResult extends Equatable {
  /// Opaque bearer token. A new login revokes the previous one.
  final String token;
  final MerchantApprovalStatus approvalStatus;

  /// FCM topic for zone-wide pushes. Only sent for approved accounts.
  final String? zoneWiseTopic;
  final String? moduleType;

  const MerchantAuthResult({
    required this.token,
    required this.approvalStatus,
    this.zoneWiseTopic,
    this.moduleType,
  });

  bool get isApproved => approvalStatus == MerchantApprovalStatus.approved;

  @override
  List<Object?> get props => [token, approvalStatus, zoneWiseTopic, moduleType];

  // Redacts the token; Equatable would otherwise print it in debug logs.
  @override
  String toString() =>
      'MerchantAuthResult(approvalStatus: $approvalStatus, '
      'zoneWiseTopic: $zoneWiseTopic, moduleType: $moduleType)';
}
