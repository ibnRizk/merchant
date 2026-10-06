import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/features/home/domain/entities/store_analytics.dart';

void main() {
  test('a period ends today and includes it', () {
    final range = AnalyticsPeriod.last7Days.rangeEndingOn(
      DateTime(2026, 3, 10, 18, 30),
    );

    expect(range.from, DateTime(2026, 3, 4));
    expect(range.to, DateTime(2026, 3, 10));
  });

  test('other orders never go negative', () {
    const StoreAnalytics analytics = StoreAnalytics(
      totalOrders: 3,
      deliveredOrders: 3,
      cancelledOrders: 1,
      totalSales: 0,
      averageOrderValue: 0,
    );

    expect(analytics.otherOrders, 0);
  });
}
