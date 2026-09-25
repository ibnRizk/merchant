import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/merchant_order.dart';
import '../../../domain/order_filter.dart';
import '../../../domain/repos/orders_repository.dart';
import '../order_notice.dart';
import 'orders_history_state.dart';

export '../../../domain/order_filter.dart' show OrderFilter;
export '../order_notice.dart';
export 'orders_history_state.dart';

/// The order-history tab: current and completed orders merged into one
/// list, with All / Completed / Cancelled tabs and a local order-id search.
class OrdersHistoryCubit extends Cubit<OrdersHistoryState> {
  final OrdersRepository _repository;

  /// Bumped on every first-page fetch, so a stale response or next page
  /// can't overwrite a newer list.
  int _generation = 0;

  OrdersHistoryCubit({required OrdersRepository repository})
    : _repository = repository,
      super(const OrdersHistoryLoading(filter: OrderFilter.all, query: ''));

  Future<void> load() async {
    final int generation = ++_generation;
    emit(OrdersHistoryLoading(filter: state.filter, query: state.query));

    final _FirstPage result = await _fetchFirstPage();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (failure) => OrdersHistoryLoadFailure(
          failure.displayMessage,
          filter: state.filter,
          query: state.query,
        ),
        (data) => OrdersHistoryLoaded(
          filter: state.filter,
          query: state.query,
          current: data.current,
          history: data.history.orders,
          page: 1,
          hasMore: data.history.hasMore,
        ),
      ),
    );
  }

  /// Pull-to-refresh: keeps the current list on screen until the new one
  /// arrives.
  Future<void> refresh() async {
    final OrdersHistoryState current = state;
    if (current is! OrdersHistoryLoaded) return load();

    final int generation = ++_generation;
    final _FirstPage result = await _fetchFirstPage();
    final OrdersHistoryState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! OrdersHistoryLoaded) {
      return;
    }

    emit(
      result.fold(
        (failure) => latest.copyWith(
          notice: OrderActionFailedNotice(failure.displayMessage),
        ),
        (data) => latest.copyWith(
          current: data.current,
          history: data.history.orders,
          page: 1,
          hasMore: data.history.hasMore,
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      ),
    );
  }

  /// Appends the next history page. Does nothing after a failure unless
  /// [retry].
  Future<void> loadMore({bool retry = false}) async {
    final OrdersHistoryState current = state;
    if (current is! OrdersHistoryLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        (current.loadMoreFailed && !retry)) {
      return;
    }

    final int generation = _generation;
    final int nextPage = current.page + 1;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final result = await _repository.getCompletedOrders(page: nextPage);
    final OrdersHistoryState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! OrdersHistoryLoaded) {
      return;
    }

    emit(
      result.fold(
        (_) => latest.copyWith(isLoadingMore: false, loadMoreFailed: true),
        (page) {
          // An order finishing meanwhile shifts the pages; skip duplicates.
          final Set<int> shown = <int>{
            for (final MerchantOrder o in latest.history) o.id,
          };
          return latest.copyWith(
            history: <MerchantOrder>[
              ...latest.history,
              ...page.orders.where((MerchantOrder o) => !shown.contains(o.id)),
            ],
            // The requested page, not the echoed `offset`: a missing echo
            // would otherwise refetch the same page forever.
            page: nextPage,
            // An empty page means the end, whatever the totals claim.
            hasMore: page.hasMore && page.orders.isNotEmpty,
            isLoadingMore: false,
          );
        },
      ),
    );
  }

  void selectFilter(OrderFilter filter) {
    if (filter == state.filter) return;
    _emitView(filter: filter);
  }

  /// Filters the loaded orders by id; no request is made.
  void search(String query) {
    final String trimmed = query.trim();
    if (trimmed == state.query) return;
    _emitView(query: trimmed);
  }

  void _emitView({OrderFilter? filter, String? query}) {
    final OrdersHistoryState current = state;
    emit(switch (current) {
      OrdersHistoryLoaded() => current.copyWith(filter: filter, query: query),
      OrdersHistoryLoading() => OrdersHistoryLoading(
        filter: filter ?? current.filter,
        query: query ?? current.query,
      ),
      OrdersHistoryLoadFailure(:final message) => OrdersHistoryLoadFailure(
        message,
        filter: filter ?? current.filter,
        query: query ?? current.query,
      ),
    });
  }

  /// Both lists in parallel; either failing fails the load, since a merged
  /// list missing one half would be misleading.
  Future<_FirstPage> _fetchFirstPage() async {
    final (
      Either<Failure, List<MerchantOrder>> current,
      Either<Failure, OrderHistoryPage> history,
    ) = await (
      _repository.getCurrentOrders(),
      _repository.getCompletedOrders(page: 1),
    ).wait;

    return current.fold(
      (Failure failure) => Left<Failure, _FirstPageData>(failure),
      (List<MerchantOrder> currentOrders) => history.fold(
        (Failure failure) => Left<Failure, _FirstPageData>(failure),
        (OrderHistoryPage page) => Right<Failure, _FirstPageData>((
          current: currentOrders,
          history: page,
        )),
      ),
    );
  }
}

typedef _FirstPageData = ({
  List<MerchantOrder> current,
  OrderHistoryPage history,
});

typedef _FirstPage = Either<Failure, _FirstPageData>;
