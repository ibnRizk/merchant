import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../domain/entities/pharmacy_request.dart';
import '../../../domain/repos/pharmacy_repository.dart';
import 'pharmacy_requests_state.dart';

export 'pharmacy_requests_state.dart';

/// The pharmacy's request inbox (`GET /vendor/pharmacy-requests`).
class PharmacyRequestsCubit extends Cubit<PharmacyRequestsState> {
  final PharmacyRepository _repository;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  PharmacyRequestsCubit({required PharmacyRepository repository})
    : _repository = repository,
      super(const PharmacyRequestsLoading());

  Future<void> load() async {
    final int generation = ++_generation;
    emit(const PharmacyRequestsLoading());
    final result = await _repository.getRequests();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => PharmacyRequestsLoadFailure(failure.displayMessage),
        PharmacyRequestsLoaded.new,
      ),
    );
  }

  /// Keeps the current list on screen until the new one arrives.
  Future<void> refresh() async {
    final PharmacyRequestsState current = state;
    if (current is! PharmacyRequestsLoaded) return load();

    final int generation = ++_generation;
    final result = await _repository.getRequests();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => PharmacyRequestsLoaded(
          current.requests,
          refreshFailure: PharmacyRefreshFailure(failure.displayMessage),
        ),
        (List<PharmacyRequest> requests) => PharmacyRequestsLoaded(requests),
      ),
    );
  }
}
