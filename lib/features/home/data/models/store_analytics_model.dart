import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';
import '../../domain/entities/store_analytics.dart';

/// Maps `/vendor/analytics`: `{orders: {total, delivered, cancelled},
/// sales: {total, average_order_value}, top_items: [...]}`. Item fields
/// aren't pinned by the docs, so common spellings are accepted.
class StoreAnalyticsModel extends StoreAnalytics {
  const StoreAnalyticsModel({
    required super.totalOrders,
    required super.deliveredOrders,
    required super.cancelledOrders,
    required super.totalSales,
    required super.averageOrderValue,
    super.topItems,
  });

  /// Throws [UnexpectedResponseException] when a figure is missing: a
  /// default zero would be shown as if it were real.
  factory StoreAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> orders = _section(json['orders']);
    final Map<String, dynamic> sales = _section(json['sales']);
    return StoreAnalyticsModel(
      totalOrders: _count(orders['total']),
      deliveredOrders: _count(orders['delivered']),
      cancelledOrders: _count(orders['cancelled']),
      totalSales: _amount(sales['total']),
      averageOrderValue: _amount(sales['average_order_value']),
      topItems: <TopItem>[
        for (final Map<String, dynamic> item in jsonMaps(json['top_items']))
          if (_topItem(item) case final TopItem topItem) topItem,
      ],
    );
  }

  static TopItem? _topItem(Map<String, dynamic> json) {
    final dynamic nested = json['item'];
    final String name = <String>[
      jsonText(json['name']),
      jsonText(json['item_name']),
      if (nested is Map) jsonText(nested['name']),
    ].firstWhere((String n) => n.isNotEmpty, orElse: () => '');
    if (name.isEmpty) return null;
    final dynamic revenue =
        json['revenue'] ?? json['total_amount'] ?? json['sales'];
    return TopItem(
      name: name,
      quantity: jsonInt(
        json['quantity'] ??
            json['total_quantity'] ??
            json['qty'] ??
            json['orders_count'],
      ),
      revenue: double.tryParse('$revenue'),
    );
  }

  static Map<String, dynamic> _section(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw const UnexpectedResponseException();
  }

  static int _count(dynamic value) {
    final int? count = int.tryParse('$value');
    if (count != null && count >= 0) return count;
    throw const UnexpectedResponseException();
  }

  static double _amount(dynamic value) {
    final double? amount = double.tryParse('$value');
    if (amount != null) return amount;
    throw const UnexpectedResponseException();
  }
}
