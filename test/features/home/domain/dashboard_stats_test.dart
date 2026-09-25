import 'package:flutter_base/features/home/domain/entities/dashboard_stats.dart';
import 'package:flutter_base/features/orders/domain/entities/merchant_order.dart';
import 'package:flutter_base/features/orders/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime now = DateTime(2026, 9, 25, 15);

MerchantOrder placed(
  int id,
  OrderStatus status, {
  DateTime? at,
  double amount = 50,
}) => MerchantOrder(
  id: id,
  status: status,
  amount: amount,
  createdAt: at ?? DateTime(2026, 9, 25, 10),
);

void main() {
  test('counts new orders', () {
    final DashboardStats stats = DashboardStats.fromOrders(
      current: <MerchantOrder>[
        placed(1, OrderStatus.pendingMerchant),
        placed(2, OrderStatus.pendingMerchant),
        placed(3, OrderStatus.accepted),
      ],
      completed: const <MerchantOrder>[],
      now: now,
    );

    expect(stats.newOrders, 2);
  });

  test('processing counts accepted and preparing, not dispatch stages', () {
    final DashboardStats stats = DashboardStats.fromOrders(
      current: <MerchantOrder>[
        placed(1, OrderStatus.accepted),
        placed(2, OrderStatus.preparing),
        placed(3, OrderStatus.dispatching),
        placed(4, OrderStatus.readyForPickup),
      ],
      completed: const <MerchantOrder>[],
      now: now,
    );

    expect(stats.processingOrders, 2);
  });

  test("today's orders counts current and completed orders placed today", () {
    final DashboardStats stats = DashboardStats.fromOrders(
      current: <MerchantOrder>[placed(1, OrderStatus.pendingMerchant)],
      completed: <MerchantOrder>[
        placed(2, OrderStatus.delivered),
        placed(3, OrderStatus.rejected),
        placed(4, OrderStatus.delivered, at: DateTime(2026, 9, 24, 23)),
      ],
      now: now,
    );

    expect(stats.ordersToday, 3);
  });

  test("today's revenue sums only orders delivered today", () {
    final DashboardStats stats = DashboardStats.fromOrders(
      current: <MerchantOrder>[placed(1, OrderStatus.preparing, amount: 99)],
      completed: <MerchantOrder>[
        placed(2, OrderStatus.delivered, amount: 40),
        placed(3, OrderStatus.delivered, amount: 25.5),
        placed(4, OrderStatus.cancelled, amount: 70),
        placed(5, OrderStatus.delivered, at: DateTime(2026, 9, 24), amount: 80),
      ],
      now: now,
    );

    expect(stats.revenueToday, 65.5);
  });

  test('an order in both lists is counted once', () {
    final DashboardStats stats = DashboardStats.fromOrders(
      current: <MerchantOrder>[placed(1, OrderStatus.outForDelivery)],
      completed: <MerchantOrder>[placed(1, OrderStatus.delivered)],
      now: now,
    );

    expect(stats.ordersToday, 1);
    expect(stats.revenueToday, 50);
  });

  test('needs no attention without new or processing orders', () {
    expect(DashboardStats.empty.needsAttention, isFalse);
  });
}
