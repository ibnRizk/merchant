import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:flutter_base/features/orders/data/repos/orders_repository_impl.dart';
import 'package:flutter_base/features/orders/domain/entities/order_status.dart';
import 'package:flutter_base/features/orders/domain/params/order_command.dart';
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

  test('a stale version fails with a ConflictFailure', () async {
    client.error = const ConflictException(message: 'order-conflict');

    final result = await repository.sendCommand(accept);

    expect(result.fold((Failure f) => f, (_) => null), isA<ConflictFailure>());
  });
}
