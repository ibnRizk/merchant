import '../../../domain/entities/merchant_order.dart';
import '../order_notice.dart';

sealed class CurrentOrdersState {
  const CurrentOrdersState();
}

final class CurrentOrdersLoading extends CurrentOrdersState {
  const CurrentOrdersLoading();
}

final class CurrentOrdersLoadFailure extends CurrentOrdersState {
  final String message;

  const CurrentOrdersLoadFailure(this.message);
}

final class CurrentOrdersLoaded extends CurrentOrdersState {
  final List<MerchantOrder> orders;

  /// Orders with a command in flight.
  final Set<int> busyIds;

  /// Describes only the emit it came with (see [OrderNotice]).
  final OrderNotice? notice;

  CurrentOrdersLoaded({
    required this.orders,
    this.busyIds = const <int>{},
    this.notice,
  });

  /// Waiting for the merchant to accept or reject.
  late final List<MerchantOrder> newOrders = <MerchantOrder>[
    for (final MerchantOrder order in orders)
      if (order.status.isNew) order,
  ];

  /// Accepted and still in progress.
  late final List<MerchantOrder> activeOrders = <MerchantOrder>[
    for (final MerchantOrder order in orders)
      if (order.status.isActive) order,
  ];

  /// [notice] is not carried over.
  CurrentOrdersLoaded copyWith({
    List<MerchantOrder>? orders,
    Set<int>? busyIds,
    OrderNotice? notice,
  }) => CurrentOrdersLoaded(
    orders: orders ?? this.orders,
    busyIds: busyIds ?? this.busyIds,
    notice: notice,
  );
}
