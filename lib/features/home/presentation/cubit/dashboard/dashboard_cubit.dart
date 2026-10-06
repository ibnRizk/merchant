import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/dashboard_stats.dart';
import '../../../domain/repos/dashboard_repository.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

/// The dashboard figures, as the server computes them.
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _repository;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  DashboardCubit({required DashboardRepository repository})
    : _repository = repository,
      super(const DashboardLoading());

  Future<void> load() async {
    final int generation = ++_generation;
    emit(const DashboardLoading());
    final Either<Failure, DashboardStats> result = await _repository
        .getDashboardStats();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (Failure failure) => DashboardLoadFailure(failure.displayMessage),
        DashboardLoaded.new,
      ),
    );
  }

  /// Keeps the current figures on screen until the new ones arrive.
  Future<void> refresh() async {
    final DashboardState current = state;
    if (current is! DashboardLoaded) return load();

    final int generation = ++_generation;
    final Either<Failure, DashboardStats> result = await _repository
        .getDashboardStats();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (Failure failure) => DashboardLoaded(
          current.stats,
          refreshFailure: DashboardRefreshFailure(failure.displayMessage),
        ),
        DashboardLoaded.new,
      ),
    );
  }

  /// Background refresh. Failures stay quiet (the next tick retries, and a
  /// pull-to-refresh still reports them); a success also recovers from a
  /// failed first load.
  Future<void> poll() async {
    if (state is DashboardLoading) return;

    final int generation = ++_generation;
    final Either<Failure, DashboardStats> result = await _repository
        .getDashboardStats();
    if (isClosed || generation != _generation) return;

    result.fold((_) {}, (DashboardStats stats) => emit(DashboardLoaded(stats)));
  }
}
