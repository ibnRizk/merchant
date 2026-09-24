import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/repos/profile_repository.dart';
import 'logout_state.dart';

export 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final ProfileRepository _repository;

  LogoutCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const LogoutInitial());

  Future<void> logout() async {
    if (state is LogoutLoading || state is LogoutSuccess) return;
    emit(const LogoutLoading());

    final result = await _repository.logout();
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => LogoutFailure(failure.displayMessage),
        (_) => const LogoutSuccess(),
      ),
    );
  }
}
