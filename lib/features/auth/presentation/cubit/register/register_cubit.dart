import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/params/register_params.dart';
import '../../../domain/repos/merchant_auth_repository.dart';
import 'register_state.dart';

export 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final MerchantAuthRepository _repository;

  RegisterCubit({required MerchantAuthRepository repository})
    : _repository = repository,
      super(const RegisterInitial());

  Future<void> register(RegisterParams params) async {
    if (state is RegisterLoading) return;
    emit(const RegisterLoading());

    final result = await _repository.register(params);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => RegisterFailure(failure.displayMessage),
        RegisterSuccess.new,
      ),
    );
  }
}
