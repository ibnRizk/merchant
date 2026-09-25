import 'package:flutter_base/features/home/domain/entities/dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

DashboardStats stats({int newOrders = 0, int processingOrders = 0}) =>
    DashboardStats(
      ordersToday: 5,
      newOrders: newOrders,
      processingOrders: processingOrders,
      revenueToday: 100,
    );

void main() {
  test('needs no attention without new or processing orders', () {
    expect(DashboardStats.empty.needsAttention, isFalse);
  });

  test('needs attention with a new order', () {
    expect(stats(newOrders: 1).needsAttention, isTrue);
  });

  test('needs attention with a processing order', () {
    expect(stats(processingOrders: 1).needsAttention, isTrue);
  });
}
