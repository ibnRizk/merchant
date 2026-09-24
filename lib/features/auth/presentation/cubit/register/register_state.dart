sealed class RegisterState {
  const RegisterState();
}

final class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

final class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

final class RegisterSuccess extends RegisterState {
  final int storeId;

  const RegisterSuccess(this.storeId);
}

final class RegisterFailure extends RegisterState {
  final String message;

  const RegisterFailure(this.message);
}
