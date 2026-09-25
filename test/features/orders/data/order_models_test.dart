import 'package:flutter_base/features/orders/data/models/order_models.dart';
import 'package:flutter_base/features/orders/domain/entities/merchant_order.dart';
import 'package:flutter_base/features/orders/domain/entities/order_line.dart';
import 'package:flutter_base/features/orders/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MerchantOrderModel.fromJson', () {
    test('reads the canonical status, version and amount', () {
      final MerchantOrder order = MerchantOrderModel.fromJson(<String, dynamic>{
        'id': 1048,
        'ssm_status': 'pending_merchant',
        'ssm_status_version': 3,
        'order_amount': '71.50',
        'details_count': 2,
      });

      expect(order.id, 1048);
      expect(order.status, OrderStatus.pendingMerchant);
      expect(order.statusVersion, 3);
      expect(order.amount, 71.5);
      expect(order.itemsCount, 2);
    });

    test('falls back to the legacy order_status', () {
      final MerchantOrder order = MerchantOrderModel.fromJson(<String, dynamic>{
        'id': 1,
        'order_status': 'canceled',
      });

      expect(order.status, OrderStatus.cancelled);
    });

    test('joins the customer name', () {
      final MerchantOrder order = MerchantOrderModel.fromJson(<String, dynamic>{
        'id': 1,
        'customer': <String, dynamic>{'f_name': 'Khalid', 'l_name': 'Ahmed'},
      });

      expect(order.customerName, 'Khalid Ahmed');
    });

    test('reads a JSON-encoded delivery address', () {
      final MerchantOrder order = MerchantOrderModel.fromJson(<String, dynamic>{
        'id': 1,
        'delivery_address':
            '{"contact_person_name":"Reem","address":"Olaya St"}',
      });

      expect(order.customerName, 'Reem');
      expect(order.address, 'Olaya St');
    });

    test('tolerates a missing version', () {
      final MerchantOrder order = MerchantOrderModel.fromJson(<String, dynamic>{
        'id': 1,
        'ssm_status': 'accepted',
      });

      expect(order.statusVersion, isNull);
    });
  });

  group('OrderLineModel.fromJson', () {
    test('reads the name from item_details and the add-on names', () {
      final OrderLine line = OrderLineModel.fromJson(<String, dynamic>{
        'id': 5,
        'item_details': '{"name":"Chicken Burger"}',
        'quantity': 2,
        'price': 20,
        'total_add_on_price': 4,
        'add_ons': <dynamic>[
          <String, dynamic>{'name': 'Cheese'},
        ],
      });

      expect(line.name, 'Chicken Burger');
      expect(line.extras, <String>['Cheese']);
      expect(line.total, 44);
    });
  });

  group('parseOrderLines', () {
    test('reads a bare array', () {
      expect(
        parseOrderLines(<dynamic>[
          <String, dynamic>{'id': 1, 'quantity': 1, 'price': 5},
        ]),
        hasLength(1),
      );
    });

    test('reads a details wrapper', () {
      expect(
        parseOrderLines(<String, dynamic>{
          'details': <dynamic>[
            <String, dynamic>{'id': 1, 'quantity': 1, 'price': 5},
          ],
        }),
        hasLength(1),
      );
    });
  });

  group('OrderHistoryPageModel.fromJson', () {
    test('reads the paging numbers', () {
      final OrderHistoryPage page = OrderHistoryPageModel.fromJson(
        <String, dynamic>{
          'total_size': 25,
          'limit': 10,
          'offset': 2,
          'orders': <dynamic>[
            <String, dynamic>{'id': 1, 'ssm_status': 'delivered'},
          ],
        },
      );

      expect(page.page, 2);
      expect(page.hasMore, isTrue);
      expect(page.orders.single.status, OrderStatus.delivered);
    });

    test('has no more on the last page', () {
      final OrderHistoryPage page = OrderHistoryPageModel.fromJson(
        <String, dynamic>{
          'total_size': 25,
          'limit': 10,
          'offset': 3,
          'orders': <dynamic>[],
        },
      );

      expect(page.hasMore, isFalse);
    });
  });

  group('parseStatusChange', () {
    test('reads the order inside a command response', () {
      final OrderStatusChange change = parseStatusChange(<String, dynamic>{
        'message': 'Order status updated successfully.',
        'order': <String, dynamic>{
          'id': 7,
          'ssm_status': 'accepted',
          'ssm_status_version': 2,
        },
      }, 7);

      expect(change.status, OrderStatus.accepted);
      expect(change.statusVersion, 2);
    });
  });
}
