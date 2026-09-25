import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/domain/params/order_command.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late OrdersRemoteDataSourceImpl dataSource;

  setUp(() {
    client = FakeDioConsumer();
    dataSource = OrdersRemoteDataSourceImpl(client: client);
  });

  test('current orders reads a bare array', () async {
    client.response = <dynamic>[
      <String, dynamic>{'id': 1, 'ssm_status': 'pending_merchant'},
    ];

    final orders = await dataSource.getCurrentOrders();

    expect(orders.single.status, OrderStatus.pendingMerchant);
    expect(client.calls.single.path, ApiEndpoints.currentOrders);
  });

  test('completed orders sends the page as offset', () async {
    client.response = <String, dynamic>{
      'total_size': 0,
      'limit': 20,
      'offset': 2,
      'orders': <dynamic>[],
    };

    await dataSource.getCompletedOrders(page: 2, limit: 20);

    expect(client.calls.single.query, <String, dynamic>{
      'offset': 2,
      'limit': 20,
    });
  });

  test('a command sends the idempotency key header', () async {
    client.response = <String, dynamic>{
      'order': <String, dynamic>{'id': 5, 'ssm_status': 'accepted'},
    };

    await dataSource.sendCommand(
      const OrderCommand(orderId: 5, action: OrderAction.accept),
      idempotencyKey: 'key-1',
    );

    expect(client.calls.single.headers, <String, String>{
      'Idempotency-Key': 'key-1',
    });
    expect(client.calls.single.path, '/vendor/orders/5/accept');
  });

  test('a command sends expected_version when known', () async {
    client.response = <String, dynamic>{
      'order': <String, dynamic>{'id': 5},
    };

    await dataSource.sendCommand(
      const OrderCommand(
        orderId: 5,
        action: OrderAction.startPreparing,
        expectedVersion: 4,
      ),
      idempotencyKey: 'key-1',
    );

    expect(client.calls.single.body, <String, dynamic>{'expected_version': 4});
    expect(client.calls.single.path, '/vendor/orders/5/start-preparing');
  });

  test('reject sends the reason code and a trimmed note', () async {
    client.response = <String, dynamic>{
      'order': <String, dynamic>{'id': 5},
    };

    await dataSource.sendCommand(
      OrderCommand.reject(
        orderId: 5,
        reason: RejectReason.storeBusy,
        note: '  back soon ',
      ),
      idempotencyKey: 'key-1',
    );

    expect(client.calls.single.body, <String, dynamic>{
      'reason': 'store_busy',
      'note': 'back soon',
    });
  });

  test('a stale version surfaces as a ConflictException', () async {
    client.error = const ConflictException(message: 'order-conflict');

    expect(
      () => dataSource.sendCommand(
        const OrderCommand(
          orderId: 5,
          action: OrderAction.accept,
          expectedVersion: 999,
        ),
        idempotencyKey: 'key-1',
      ),
      throwsA(isA<ConflictException>()),
    );
  });
}
