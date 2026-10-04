import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/account_deletion.dart';
import '../../../domain/repos/profile_repository.dart';
import 'delete_account_state.dart';

export 'delete_account_state.dart';

/// Sends the account deletion request. The screen ends the session once it
/// succeeds.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final ProfileRepository _repository;

  DeleteAccountCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const DeleteAccountInitial());

  Future<void> requestDeletion({String? reason}) async {
    if (state is DeleteAccountLoading || state is DeleteAccountRequested) {
      return;
    }
    emit(const DeleteAccountLoading());

    final result = await _repository.requestAccountDeletion(reason: reason);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => failure is AccountDeletionBlockedFailure
            ? DeleteAccountBlocked(failure.reason)
            : DeleteAccountFailure(failure.displayMessage),
        (_) => const DeleteAccountRequested(),
      ),
    );
  }
}
