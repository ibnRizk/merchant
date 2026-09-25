import 'package:equatable/equatable.dart';

/// The dashboard's four tiles and the "needs attention" counts, as
/// `/vendor/dashboard-stats` reports them.
class DashboardStats extends Equatable {
  /// Orders placed today, whatever their status.
  final int ordersToday;

  /// Waiting for the merchant to accept or reject.
  final int newOrders;

  /// Accepted and still in progress.
  final int processingOrders;

  /// Gross value of orders delivered today.
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

  bool get needsAttention => newOrders > 0 || processingOrders > 0;

  @override
  List<Object?> get props => [
    ordersToday,
    newOrders,
    processingOrders,
    revenueToday,
  ];
}
