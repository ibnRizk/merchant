import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../notifications/domain/repos/push_token_repository.dart';
import '../../../domain/repos/profile_repository.dart';
import 'logout_state.dart';

export 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final ProfileRepository _repository;
  final PushTokenRepository _pushTokens;

  LogoutCubit({
    required ProfileRepository repository,
    required PushTokenRepository pushTokens,
  }) : _repository = repository,
       _pushTokens = pushTokens,
       super(const LogoutInitial());

  Future<void> logout() async {
    if (state is LogoutLoading || state is LogoutSuccess) return;
    emit(const LogoutLoading());

    // First, while the session token still authorizes the call; otherwise
    // the server keeps pushing to a signed-out device. Best effort, so its
    // result never blocks the logout.
    await _pushTokens.unregisterDevice();
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
