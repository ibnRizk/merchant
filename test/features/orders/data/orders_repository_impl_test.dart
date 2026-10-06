import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:ssm_merchant/features/orders/data/repos/orders_repository_impl.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/domain/failures/stale_order_failure.dart';
import 'package:ssm_merchant/features/orders/domain/params/order_command.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late OrdersRepositoryImpl repository;
  late int keysIssued;

  const OrderCommand accept = OrderCommand(
    orderId: 5,
    action: OrderAction.accept,
    expectedVersion: 1,
  );

  List<String?> sentKeys() => <String?>[
    for (final call in client.calls) call.headers?['Idempotency-Key'],
  ];

  setUp(() {
    client = FakeDioConsumer()
      ..response = <String, dynamic>{
        'order': <String, dynamic>{'id': 5, 'ssm_status': 'accepted'},
      };
    keysIssued = 0;
    repository = OrdersRepositoryImpl(
      remote: OrdersRemoteDataSourceImpl(client: client),
      newKey: () => 'key-${++keysIssued}',
    );
  });

  test('a retry after a network failure reuses the key', () async {
    client.error = const InternetConnectionException();
    await repository.sendCommand(accept);
    client.error = null;

    await repository.sendCommand(accept);

    expect(sentKeys(), <String>['key-1', 'key-1']);
  });

  test('a command after a success gets a new key', () async {
    await repository.sendCommand(accept);
    await repository.sendCommand(accept);

    expect(sentKeys(), <String>['key-1', 'key-2']);
  });

  test('a retry after a refused command gets a new key', () async {
    client.error = const ServerException(message: 'order-transition-invalid');
    await repository.sendCommand(accept);
    client.error = null;

    await repository.sendCommand(accept);

    expect(sentKeys(), <String>['key-1', 'key-2']);
  });

  test('a different command does not reuse a pending key', () async {
    client.error = const InternetConnectionException();
    await repository.sendCommand(accept);
    client.error = null;

    await repository.sendCommand(
      const OrderCommand(orderId: 6, action: OrderAction.accept),
    );

    expect(sentKeys(), <String>['key-1', 'key-2']);
  });

  test('a success drops other pending keys for the same order', () async {
    const OrderCommand reject = OrderCommand(
      orderId: 5,
      action: OrderAction.reject,
      reason: 'other',
    );
    client.error = const InternetConnectionException();
    await repository.sendCommand(reject);
    client.error = null;
    await repository.sendCommand(accept);

    await repository.sendCommand(reject);

    expect(sentKeys(), <String>['key-1', 'key-2', 'key-3']);
  });

  test('a stale version fails with a ConflictFailure', () async {
    client.error = const ConflictException(message: 'order-conflict');

    final result = await repository.sendCommand(accept);

    expect(result.fold((Failure f) => f, (_) => null), isA<ConflictFailure>());
  });

  test('a 404 on a command fails with a StaleOrderFailure', () async {
    client.error = const ServerException(message: 'gone', statusCode: 404);

    final result = await repository.sendCommand(accept);

    expect(
      result.fold((Failure f) => f, (_) => null),
      isA<StaleOrderFailure>(),
    );
  });

  test('every command sends a UUID v4 idempotency key by default', () async {
    repository = OrdersRepositoryImpl(
      remote: OrdersRemoteDataSourceImpl(client: client),
    );
    final RegExp uuidV4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    for (final OrderAction action in OrderAction.values) {
      await repository.sendCommand(OrderCommand(orderId: 5, action: action));
    }

    expect(sentKeys(), hasLength(OrderAction.values.length));
    expect(sentKeys(), everyElement(matches(uuidV4)));
    expect(sentKeys().toSet(), hasLength(OrderAction.values.length));
  });
}
