import 'package:equatable/equatable.dart';

/// Store performance over a date range, as `GET /vendor/analytics`
/// reports it.
class StoreAnalytics extends Equatable {
  final int totalOrders;
  final int deliveredOrders;
  final int cancelledOrders;

  /// Gross sales in the store currency.
  final double totalSales;
  final double averageOrderValue;

  /// Best sellers, best first.
  final List<TopItem> topItems;

  const StoreAnalytics({
    required this.totalOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.totalSales,
    required this.averageOrderValue,
    this.topItems = const <TopItem>[],
  });

  /// Orders neither delivered nor cancelled yet (in progress, or ended in
  /// a state the API doesn't count). Never negative.
  int get otherOrders {
    final int other = totalOrders - deliveredOrders - cancelledOrders;
    return other < 0 ? 0 : other;
  }

  @override
  List<Object?> get props => [
    totalOrders,
    deliveredOrders,
    cancelledOrders,
    totalSales,
    averageOrderValue,
    topItems,
  ];
}

class TopItem extends Equatable {
  final String name;

  /// Units sold.
  final int quantity;

  /// Sales of this item, when the API reports it.
  final double? revenue;

  const TopItem({required this.name, required this.quantity, this.revenue});

  @override
  List<Object?> get props => [name, quantity, revenue];
}

/// The ranges the dashboard offers. Each ends today, inclusive.
enum AnalyticsPeriod {
  last7Days(7),
  last30Days(30),
  last90Days(90);

  final int days;

  const AnalyticsPeriod(this.days);

  /// The first and last day (dates only) for [now].
  ({DateTime from, DateTime to}) rangeEndingOn(DateTime now) {
    final DateTime to = DateTime(now.year, now.month, now.day);
    return (from: to.subtract(Duration(days: days - 1)), to: to);
  }
}
