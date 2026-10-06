import '../../../../core/error/exceptions.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Maps `/vendor/dashboard-stats`:
/// `{"today": {"orders_count", "gross_revenue": "0.00", ...},
///   "current": {"new_orders_count", "active_orders_count"}, ...}`.
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.ordersToday,
    required super.newOrders,
    required super.processingOrders,
    required super.revenueToday,
  });

  /// Throws [ServerException] when a figure is missing or malformed: a
  /// default zero would be shown as if it were the real count.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> today = _section(json['today']);
    final Map<String, dynamic> current = _section(json['current']);

    return DashboardStatsModel(
      ordersToday: _count(today['orders_count']),
      newOrders: _count(current['new_orders_count']),
      processingOrders: _count(current['active_orders_count']),
      revenueToday: _amount(today['gross_revenue']),
    );
  }

  static Map<String, dynamic> _section(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw ServerException.unexpectedResponse();
  }

  static int _count(dynamic value) {
    final int? count = int.tryParse('$value');
    if (count != null && count >= 0) return count;
    throw ServerException.unexpectedResponse();
  }

  /// The API sends money as a decimal string, e.g. `"125.50"`.
  static double _amount(dynamic value) {
    final double? amount = double.tryParse('$value');
    if (amount != null) return amount;
    throw ServerException.unexpectedResponse();
  }
}
