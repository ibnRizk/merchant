import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/entities/merchant_approval_status.dart';
import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/onboarding_status.dart';
import '../../../domain/repos/merchant_auth_repository.dart';
import 'pending_approval_state.dart';

export 'pending_approval_state.dart';

/// The pending / rejected / suspended screen: re-checks the account status
/// and lets the merchant sign out.
class PendingApprovalCubit extends Cubit<PendingApprovalState> {
  final MerchantAuthRepository _repository;

  PendingApprovalCubit({
    required MerchantAuthRepository repository,
    required MerchantApprovalStatus initialStatus,
  }) : _repository = repository,
       super(PendingApprovalState(approvalStatus: initialStatus));

  /// [silent] is the automatic check when the screen opens: it only updates
  /// the status and reason, and announces nothing unless the account can
  /// now operate.
  Future<void> check({bool silent = false}) async {
    if (state.isChecking || state.status == PendingApprovalStatus.signedOut) {
      return;
    }
    emit(state.copyWith(status: PendingApprovalStatus.checking));

    final result = await _repository.getOnboardingStatus();
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => state.copyWith(
          status: silent
              ? PendingApprovalStatus.idle
              : PendingApprovalStatus.failure,
          errorMessage: silent ? null : failure.displayMessage,
        ),
        (OnboardingStatus onboarding) => onboarding.canOperate
            ? state.copyWith(status: PendingApprovalStatus.approved)
            : state.copyWith(
                approvalStatus: onboarding.status,
                rejectionReason: onboarding.rejectionReason,
                status: silent
                    ? PendingApprovalStatus.idle
                    : PendingApprovalStatus.stillRestricted,
              ),
      ),
    );
  }

  Future<void> signOut() async {
    if (state.isChecking || state.status == PendingApprovalStatus.signedOut) {
      return;
    }
    final result = await _repository.clearSession();
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: PendingApprovalStatus.failure,
          errorMessage: failure.displayMessage,
        ),
        (_) => state.copyWith(status: PendingApprovalStatus.signedOut),
      ),
    );
  }
}
