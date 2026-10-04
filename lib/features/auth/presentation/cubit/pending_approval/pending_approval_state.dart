import 'package:equatable/equatable.dart';

import '../../../../../core/entities/merchant_approval_status.dart';

enum PendingApprovalStatus {
  idle,
  checking,

  /// The account can operate now: leave for home.
  approved,

  /// An explicit "check again" found nothing new.
  stillRestricted,
  failure,

  /// The token is gone: leave for login.
  signedOut,
}

class PendingApprovalState extends Equatable {
  /// Pending, rejected or suspended (never approved while on this screen).
  final MerchantApprovalStatus approvalStatus;
  final String? rejectionReason;
  final PendingApprovalStatus status;

  /// Set only when [status] is [PendingApprovalStatus.failure].
  final String? errorMessage;

  const PendingApprovalState({
    required this.approvalStatus,
    this.rejectionReason,
    this.status = PendingApprovalStatus.idle,
    this.errorMessage,
  });

  bool get isChecking => status == PendingApprovalStatus.checking;

  /// Clears [errorMessage] unless a new one is passed.
  PendingApprovalState copyWith({
    MerchantApprovalStatus? approvalStatus,
    String? rejectionReason,
    PendingApprovalStatus? status,
    String? errorMessage,
  }) {
    return PendingApprovalState(
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    approvalStatus,
    rejectionReason,
    status,
    errorMessage,
  ];
}
