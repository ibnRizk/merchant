import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/params/login_params.dart';
import '../../../domain/repos/merchant_auth_repository.dart';
import 'login_state.dart';

export 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final MerchantAuthRepository _repository;

  LoginCubit({required MerchantAuthRepository repository})
    : _repository = repository,
      super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    if (state is LoginLoading) return;
    emit(const LoginLoading());

    final result = await _repository.login(
      LoginParams(email: email, password: password),
    );
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => LoginFailure(failure.displayMessage),
        LoginSuccess.new,
      ),
    );
  }
}
