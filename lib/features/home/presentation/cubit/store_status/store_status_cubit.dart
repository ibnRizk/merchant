import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/repos/store_status_repository.dart';
import 'store_status_state.dart';

export 'store_status_state.dart';

/// Opens or closes the store. The switch flips right away and reverts if
/// the server refuses.
class StoreStatusCubit extends Cubit<StoreStatusState> {
  final StoreStatusRepository _repository;

  StoreStatusCubit({required StoreStatusRepository repository})
    : _repository = repository,
      super(const StoreStatusState());

  /// The status as the profile reports it. Ignored while a change is in
  /// flight, so a profile load can't undo the optimistic value.
  void seed({required bool isOpen}) {
    if (state.isUpdating || state.isOpen == isOpen) return;
    emit(StoreStatusState(isOpen: isOpen));
  }

  Future<void> setOpen(bool isOpen) async {
    final bool? previous = state.isOpen;
    if (previous == null || state.isUpdating || previous == isOpen) return;

    emit(StoreStatusState(isOpen: isOpen, isUpdating: true));
    final result = await _repository.setStoreOpen(isOpen: isOpen);
    if (isClosed) return;

    emit(
      result.fold(
        (failure) => StoreStatusState(
          isOpen: previous,
          failure: StoreStatusFailure(failure.displayMessage),
        ),
        (bool serverIsOpen) => StoreStatusState(isOpen: serverIsOpen),
      ),
    );
  }
}
