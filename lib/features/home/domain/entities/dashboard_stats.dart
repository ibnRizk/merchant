import 'package:equatable/equatable.dart';

import '../../../orders/domain/entities/merchant_order.dart';
import '../../../orders/domain/order_filter.dart';

/// The dashboard's four tiles and the "needs attention" counts.
class DashboardStats extends Equatable {
  /// Orders placed today, whatever their status.
  final int ordersToday;

  /// Waiting for the merchant to accept or reject.
  final int newOrders;

  /// Accepted or preparing: the merchant still has to move them.
  final int processingOrders;

  /// Delivered orders placed today.
  final double revenueToday;

  const DashboardStats({
    required this.ordersToday,
    required this.newOrders,
    required this.processingOrders,
    required this.revenueToday,
  });

  static const DashboardStats empty = DashboardStats(
    ordersToday: 0,
    newOrders: 0,
    processingOrders: 0,
    revenueToday: 0,
  );

  // TODO: Connect to a dedicated dashboard API when the backend provides one.
  // Until then the "today" figures are derived from current orders plus the
  // first page of completed orders, so a very busy day can undercount.
  factory DashboardStats.fromOrders({
    required List<MerchantOrder> current,
    required List<MerchantOrder> completed,
    required DateTime now,
  }) {
    bool isToday(MerchantOrder order) {
      final DateTime? time = order.createdAt;
      return time != null &&
          time.year == now.year &&
          time.month == now.month &&
          time.day == now.day;
    }

    int newOrders = 0;
    int processingOrders = 0;
    for (final MerchantOrder order in current) {
      if (order.status.isNew) {
        newOrders++;
      } else if (order.status.nextAction != null) {
        processingOrders++;
      }
    }

    int ordersToday = 0;
    double revenueToday = 0;
    for (final MerchantOrder order in mergeOrders(current, completed)) {
      if (!isToday(order)) continue;
      ordersToday++;
      if (order.status.isCompleted) revenueToday += order.amount;
    }

    return DashboardStats(
      ordersToday: ordersToday,
      newOrders: newOrders,
      processingOrders: processingOrders,
      revenueToday: revenueToday,
    );
  }

  bool get needsAttention => newOrders > 0 || processingOrders > 0;

  @override
  List<Object?> get props => [
    ordersToday,
    newOrders,
    processingOrders,
    revenueToday,
  ];
}
