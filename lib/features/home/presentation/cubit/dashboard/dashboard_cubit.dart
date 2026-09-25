import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../../orders/domain/entities/merchant_order.dart';
import '../../../../orders/domain/repos/orders_repository.dart';
import '../../../domain/entities/dashboard_stats.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

/// The dashboard figures, derived from the orders endpoints until the
/// backend offers a dedicated dashboard API (see [DashboardStats]).
class DashboardCubit extends Cubit<DashboardState> {
  final OrdersRepository _repository;
  final DateTime Function() _now;

  /// Bumped on every fetch, so an older response can't overwrite a newer one.
  int _generation = 0;

  DashboardCubit({
    required OrdersRepository repository,
    DateTime Function() now = DateTime.now,
  }) : _repository = repository,
       _now = now,
       super(const DashboardLoading());

  Future<void> load() async {
    final int generation = ++_generation;
    emit(const DashboardLoading());
    final Either<Failure, DashboardStats> result = await _fetch();
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
    final Either<Failure, DashboardStats> result = await _fetch();
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

  /// Both lists in parallel; either failing fails the load, since figures
  /// built from half the data would be wrong without saying so.
  Future<Either<Failure, DashboardStats>> _fetch() async {
    final (
      Either<Failure, List<MerchantOrder>> current,
      Either<Failure, OrderHistoryPage> completed,
    ) = await (
      _repository.getCurrentOrders(),
      _repository.getCompletedOrders(page: 1),
    ).wait;

    return current.fold(
      (Failure failure) => Left<Failure, DashboardStats>(failure),
      (List<MerchantOrder> currentOrders) => completed.fold(
        (Failure failure) => Left<Failure, DashboardStats>(failure),
        (OrderHistoryPage page) => Right<Failure, DashboardStats>(
          DashboardStats.fromOrders(
            current: currentOrders,
            completed: page.orders,
            now: _now(),
          ),
        ),
      ),
    );
  }
}
