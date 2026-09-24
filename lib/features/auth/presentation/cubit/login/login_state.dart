import '../../../domain/entities/merchant_auth_result.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  final MerchantAuthResult result;

  const LoginSuccess(this.result);
}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);
}
