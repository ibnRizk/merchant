import 'package:equatable/equatable.dart';

/// Body of `POST /auth/vendor/verify-token`: checks the reset OTP sent by
/// forgot-password.
class VerifyTokenParams extends Equatable {
  final String email;
  final String resetToken;

  const VerifyTokenParams({required this.email, required this.resetToken});

  @override
  List<Object?> get props => [email, resetToken];

  @override
  String toString() => 'VerifyTokenParams(email: $email)';
}
