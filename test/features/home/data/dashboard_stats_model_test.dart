import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/home/data/models/dashboard_stats_model.dart';
import 'package:ssm_merchant/features/home/domain/entities/dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

/// The documented `/vendor/dashboard-stats` response.
Map<String, dynamic> response() => <String, dynamic>{
  'store_id': 5,
  'currency': 'SAR',
  'timezone': 'US/Central',
  'date': '2026-09-25',
  'today': <String, dynamic>{
    'orders_count': 12,
    'new_orders_count': 4,
    'delivered_orders_count': 7,
    'cancelled_orders_count': 1,
    'gross_revenue': '845.50',
  },
  'current': <String, dynamic>{'new_orders_count': 3, 'active_orders_count': 2},
  'all_time': <String, dynamic>{
    'orders_count': 400,
    'delivered_orders_count': 380,
    'gross_revenue': '51200.00',
  },
  'revenue_definition': 'Gross value of delivered orders.',
};

void main() {
  test('maps the figures from their sections', () {
    // Equatable compares runtime types, so compare the fields.
    expect(
      DashboardStatsModel.fromJson(response()).props,
      const DashboardStats(
        ordersToday: 12,
        newOrders: 3,
        processingOrders: 2,
        revenueToday: 845.5,
      ).props,
    );
  });

  test('new orders come from current, not from today', () {
    final Map<String, dynamic> json = response();
    (json['today'] as Map<String, dynamic>)['new_orders_count'] = 99;

    expect(DashboardStatsModel.fromJson(json).newOrders, 3);
  });

  test('accepts counts sent as strings', () {
    final Map<String, dynamic> json = response();
    (json['today'] as Map<String, dynamic>)['orders_count'] = '12';

    expect(DashboardStatsModel.fromJson(json).ordersToday, 12);
  });

  test('throws when a section is missing', () {
    final Map<String, dynamic> json = response()..remove('current');

    expect(
      () => DashboardStatsModel.fromJson(json),
      throwsA(isA<ServerException>()),
    );
  });

  test('throws when a count is missing', () {
    final Map<String, dynamic> json = response();
    (json['today'] as Map<String, dynamic>).remove('orders_count');

    expect(
      () => DashboardStatsModel.fromJson(json),
      throwsA(isA<ServerException>()),
    );
  });

  test('throws when the revenue is not a number', () {
    final Map<String, dynamic> json = response();
    (json['today'] as Map<String, dynamic>)['gross_revenue'] = 'n/a';

    expect(
      () => DashboardStatsModel.fromJson(json),
      throwsA(isA<ServerException>()),
    );
  });
}
