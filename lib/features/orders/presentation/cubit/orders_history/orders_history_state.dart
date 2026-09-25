import '../../../domain/entities/merchant_order.dart';
import '../../../domain/order_filter.dart';
import '../order_notice.dart';

sealed class OrdersHistoryState {
  final OrderFilter filter;

  /// The order-id search text; empty for no search.
  final String query;

  const OrdersHistoryState({required this.filter, required this.query});
}

final class OrdersHistoryLoading extends OrdersHistoryState {
  const OrdersHistoryLoading({required super.filter, required super.query});
}

final class OrdersHistoryLoadFailure extends OrdersHistoryState {
  final String message;

  const OrdersHistoryLoadFailure(
    this.message, {
    required super.filter,
    required super.query,
  });
}

final class OrdersHistoryLoaded extends OrdersHistoryState {
  /// From `current-orders`: new and active.
  final List<MerchantOrder> current;

  /// From `completed-orders`, all pages loaded so far.
  final List<MerchantOrder> history;

  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// The next page failed. Scrolling stops fetching until a retry.
  final bool loadMoreFailed;

  /// E.g. a failed pull-to-refresh; the old list stays on screen.
  /// Describes only the emit it came with.
  final OrderNotice? notice;

  OrdersHistoryLoaded({
    required super.filter,
    required super.query,
    required this.current,
    required this.history,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.notice,
  });

  /// What the selected tab shows, computed once per state.
  late final List<MerchantOrder> visibleOrders = filterOrders(
    mergeOrders(current, history),
    filter: filter,
    query: query,
  );

  /// [notice] is not carried over.
  OrdersHistoryLoaded copyWith({
    OrderFilter? filter,
    String? query,
    List<MerchantOrder>? current,
    List<MerchantOrder>? history,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    OrderNotice? notice,
  }) => OrdersHistoryLoaded(
    filter: filter ?? this.filter,
    query: query ?? this.query,
    current: current ?? this.current,
    history: history ?? this.history,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    notice: notice,
  );
}
