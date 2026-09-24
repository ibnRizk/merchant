import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/params/reset_password_params.dart';
import '../../../domain/params/verify_token_params.dart';
import '../../../domain/repos/merchant_auth_repository.dart';
import 'forgot_password_state.dart';

export 'forgot_password_state.dart';

/// Drives request OTP -> verify OTP -> set new password.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final MerchantAuthRepository _repository;

  /// Kept out of the state so it never shows up in state logs.
  String _resetToken = '';

  ForgotPasswordCubit({required MerchantAuthRepository repository})
    : _repository = repository,
      super(const ForgotPasswordState());

  Future<void> requestOtp(String email) async {
    final String trimmed = email.trim();
    await _run(
      () => _repository.forgotPassword(trimmed),
      onSuccess: () => state.copyWith(
        step: ForgotPasswordStep.verifyOtp,
        status: ForgotPasswordStatus.idle,
        email: trimmed,
      ),
    );
  }

  Future<void> resendOtp() async {
    await _run(
      () => _repository.forgotPassword(state.email),
      onSuccess: () => state.copyWith(status: ForgotPasswordStatus.otpResent),
    );
  }

  Future<void> verifyOtp(String code) async {
    await _run(
      () => _repository.verifyToken(
        VerifyTokenParams(email: state.email, resetToken: code),
      ),
      onSuccess: () {
        _resetToken = code;
        return state.copyWith(
          step: ForgotPasswordStep.resetPassword,
          status: ForgotPasswordStatus.idle,
        );
      },
    );
  }

  Future<void> resetPassword({
    required String password,
    required String confirmPassword,
  }) async {
    await _run(
      () => _repository.resetPassword(
        ResetPasswordParams(
          email: state.email,
          resetToken: _resetToken,
          password: password,
          confirmPassword: confirmPassword,
        ),
      ),
      onSuccess: () => state.copyWith(status: ForgotPasswordStatus.completed),
    );
  }

  /// Goes back one step. Returns false on the first step, where the route
  /// itself should pop.
  bool back() {
    if (state.isLoading) return true;
    final ForgotPasswordStep? previous = switch (state.step) {
      ForgotPasswordStep.requestOtp => null,
      ForgotPasswordStep.verifyOtp => ForgotPasswordStep.requestOtp,
      ForgotPasswordStep.resetPassword => ForgotPasswordStep.verifyOtp,
    };
    if (previous == null) return false;
    emit(state.copyWith(step: previous, status: ForgotPasswordStatus.idle));
    return true;
  }

  Future<void> _run(
    Future<Either<Failure, Unit>> Function() call, {
    required ForgotPasswordState Function() onSuccess,
  }) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    final Either<Failure, Unit> result = await call();
    if (isClosed) return;

    emit(
      result.fold(
        (Failure failure) => state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: failure.displayMessage,
        ),
        (_) => onSuccess(),
      ),
    );
  }
}
