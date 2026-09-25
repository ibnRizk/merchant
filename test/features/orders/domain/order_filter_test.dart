import 'package:ssm_merchant/features/orders/domain/entities/merchant_order.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/domain/order_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  List<int> ids(List<MerchantOrder> orders) => <int>[
    for (final MerchantOrder o in orders) o.id,
  ];

  group('mergeOrders', () {
    test('sorts newest first', () {
      final List<MerchantOrder> merged = mergeOrders(
        <MerchantOrder>[anOrder(1, createdAt: DateTime(2026, 9, 25, 12))],
        <MerchantOrder>[
          anOrder(
            2,
            status: OrderStatus.delivered,
            createdAt: DateTime(2026, 9, 24),
          ),
          anOrder(
            3,
            status: OrderStatus.delivered,
            createdAt: DateTime(2026, 9, 25, 13),
          ),
        ],
      );

      expect(ids(merged), <int>[3, 1, 2]);
    });

    test('keeps the history copy of an order in both lists', () {
      final List<MerchantOrder> merged = mergeOrders(
        <MerchantOrder>[anOrder(1, status: OrderStatus.outForDelivery)],
        <MerchantOrder>[anOrder(1, status: OrderStatus.delivered)],
      );

      expect(merged.single.status, OrderStatus.delivered);
    });
  });

  group('filterOrders', () {
    final List<MerchantOrder> orders = <MerchantOrder>[
      anOrder(1048, status: OrderStatus.delivered),
      anOrder(1039, status: OrderStatus.rejected),
      anOrder(1038, status: OrderStatus.cancelled),
      anOrder(1027, status: OrderStatus.preparing),
    ];

    test('all shows every order', () {
      expect(filterOrders(orders, filter: OrderFilter.all), hasLength(4));
    });

    test('completed shows delivered orders only', () {
      expect(ids(filterOrders(orders, filter: OrderFilter.completed)), <int>[
        1048,
      ]);
    });

    test('cancelled includes rejected orders', () {
      expect(ids(filterOrders(orders, filter: OrderFilter.cancelled)), <int>[
        1039,
        1038,
      ]);
    });

    test('search matches part of the id', () {
      expect(
        ids(filterOrders(orders, filter: OrderFilter.all, query: '103')),
        <int>[1039, 1038],
      );
    });

    test('search ignores # and prefixes', () {
      expect(
        ids(filterOrders(orders, filter: OrderFilter.all, query: '#SSM-1048')),
        <int>[1048],
      );
    });

    test('search combines with the tab', () {
      expect(
        filterOrders(orders, filter: OrderFilter.completed, query: '1039'),
        isEmpty,
      );
    });
  });

  test('orderQueryDigits converts Arabic-Indic digits', () {
    expect(orderQueryDigits('١٠٤٨'), '1048');
  });
}
