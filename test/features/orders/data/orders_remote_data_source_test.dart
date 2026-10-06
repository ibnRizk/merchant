import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_merchant/features/orders/data/exceptions/transition_rejected_exception.dart';
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

  test('retry dispatch posts to the retry-dispatch route with a key', () async {
    client.response = <String, dynamic>{
      'order': <String, dynamic>{'id': 5, 'ssm_status': 'dispatching'},
    };

    final change = await dataSource.sendCommand(
      const OrderCommand(orderId: 5, action: OrderAction.retryDispatch),
      idempotencyKey: 'key-1',
    );

    expect(client.calls.single.path, '/vendor/orders/5/retry-dispatch');
    expect(client.calls.single.headers, <String, String>{
      'Idempotency-Key': 'key-1',
    });
    expect(change.status, OrderStatus.dispatching);
  });

  group('a refused transition', () {
    Future<void> send() => dataSource.sendCommand(
      const OrderCommand(orderId: 5, action: OrderAction.startPreparing),
      idempotencyKey: 'key-1',
    );

    test('422 order_transition_invalid becomes TransitionRejected', () {
      client.error = const ServerException(
        message: 'Order cannot move to preparing.',
        statusCode: 422,
        code: 'order_transition_invalid',
      );

      expect(
        send,
        throwsA(
          isA<TransitionRejectedException>().having(
            (TransitionRejectedException e) => e.message,
            'message',
            'Order cannot move to preparing.',
          ),
        ),
      );
    });

    test('404 becomes TransitionRejected', () {
      client.error = const ServerException(statusCode: 404);

      expect(send, throwsA(isA<TransitionRejectedException>()));
    });

    test('a 422 validation error stays a ServerException', () {
      client.error = const ServerException(
        message: 'The reason field is required.',
        statusCode: 422,
      );

      expect(
        send,
        throwsA(
          isA<ServerException>().having(
            (ServerException e) => e.statusCode,
            'statusCode',
            422,
          ),
        ),
      );
    });

    test('a 500 stays a ServerException', () {
      client.error = const ServerException(statusCode: 500);

      expect(send, throwsA(isA<ServerException>()));
    });
  });
}
