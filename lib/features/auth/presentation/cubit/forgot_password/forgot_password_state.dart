import 'package:equatable/equatable.dart';

enum ForgotPasswordStep { requestOtp, verifyOtp, resetPassword }

enum ForgotPasswordStatus {
  idle,
  loading,
  failure,

  /// A new OTP was sent from the verify step.
  otpResent,

  /// Password changed; the flow is over.
  completed,
}

/// One state for the whole 3-step flow, so going back a step keeps the email.
class ForgotPasswordState extends Equatable {
  final ForgotPasswordStep step;
  final ForgotPasswordStatus status;
  final String email;

  /// Set only when [status] is [ForgotPasswordStatus.failure].
  final String? errorMessage;

  const ForgotPasswordState({
    this.step = ForgotPasswordStep.requestOtp,
    this.status = ForgotPasswordStatus.idle,
    this.email = '',
    this.errorMessage,
  });

  bool get isLoading => status == ForgotPasswordStatus.loading;

  /// Clears [errorMessage] unless a new one is passed.
  ForgotPasswordState copyWith({
    ForgotPasswordStep? step,
    ForgotPasswordStatus? status,
    String? email,
    String? errorMessage,
  }) {
    return ForgotPasswordState(
      step: step ?? this.step,
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [step, status, email, errorMessage];
}
