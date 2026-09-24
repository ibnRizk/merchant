import 'package:equatable/equatable.dart';

/// Body of `PUT /auth/vendor/reset-password`.
class ResetPasswordParams extends Equatable {
  final String email;
  final String resetToken;
  final String password;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.email,
    required this.resetToken,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, resetToken, password, confirmPassword];

  @override
  String toString() => 'ResetPasswordParams(email: $email)';
}
