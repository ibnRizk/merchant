import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/orders/domain/entities/merchant_order.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/domain/params/order_command.dart';
import 'package:ssm_merchant/features/orders/presentation/cubit/current_orders/current_orders_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late CurrentOrdersCubit cubit;

  CurrentOrdersLoaded loaded() => cubit.state as CurrentOrdersLoaded;
  MerchantOrder orderById(int id) =>
      loaded().orders.firstWhere((MerchantOrder o) => o.id == id);

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = CurrentOrdersCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('splits new and active orders', () async {
      await cubit.load();

      expect(loaded().newOrders.map((MerchantOrder o) => o.id), <int>[1]);
      expect(loaded().activeOrders.map((MerchantOrder o) => o.id), <int>[2, 3]);
    });

    test('shows the failure message', () async {
      repository.onGetCurrent = () async =>
          const Left(NetworkFailure(message: 'offline'));

      await cubit.load();

      expect((cubit.state as CurrentOrdersLoadFailure).message, 'offline');
    });
  });

  group('accept', () {
    test('sends the last seen version', () async {
      await cubit.load();

      await cubit.accept(orderById(1));

      expect(repository.commands.single.action, OrderAction.accept);
      expect(repository.commands.single.expectedVersion, 1);
    });

    test('moves the order to active with the new version', () async {
      await cubit.load();

      await cubit.accept(orderById(1));

      expect(orderById(1).status, OrderStatus.accepted);
      expect(orderById(1).statusVersion, 2);
      expect(loaded().newOrders, isEmpty);
      expect(loaded().notice, isA<OrderUpdatedNotice>());
    });

    test('ignores a second tap while the first is in flight', () async {
      await cubit.load();
      final Completer<Either<Failure, OrderStatusChange>> pending = Completer();
      repository.onSendCommand = (_) => pending.future;

      final Future<void> first = cubit.accept(orderById(1));
      await cubit.accept(orderById(1));
      pending.complete(const Left(ServerFailure(message: 'refused')));
      await first;

      expect(repository.commands, hasLength(1));
    });
  });

  group('failures', () {
    test('a conflict announces it and reloads the list', () async {
      await cubit.load();
      repository.onSendCommand = (_) async =>
          const Left(ConflictFailure(message: 'order-conflict'));
      final Future<CurrentOrdersState> conflict = cubit.stream.firstWhere(
        (CurrentOrdersState s) =>
            s is CurrentOrdersLoaded && s.notice is OrderConflictNotice,
      );

      await cubit.accept(orderById(1));
      await conflict;
      await Future<void>.delayed(Duration.zero);

      expect(repository.currentRequests, 2);
      expect(loaded().busyIds, isEmpty);
    });

    test('another failure shows its message and keeps the order', () async {
      await cubit.load();
      repository.onSendCommand = (_) async =>
          const Left(ServerFailure(message: 'order-transition-invalid'));

      await cubit.accept(orderById(1));

      expect(
        (loaded().notice as OrderActionFailedNotice).message,
        'order-transition-invalid',
      );
      expect(orderById(1).status, OrderStatus.pendingMerchant);
    });
  });

  group('advance', () {
    test('starts preparing an accepted order', () async {
      await cubit.load();

      await cubit.advance(orderById(2));

      expect(repository.commands.single.action, OrderAction.startPreparing);
      expect(orderById(2).status, OrderStatus.preparing);
    });

    test('marks a preparing order ready for pickup', () async {
      await cubit.load();

      await cubit.advance(orderById(3));

      expect(repository.commands.single.action, OrderAction.readyForPickup);
    });

    test('does nothing for a new order', () async {
      await cubit.load();

      await cubit.advance(orderById(1));

      expect(repository.commands, isEmpty);
    });
  });

  test('reject sends the reason and removes the order', () async {
    await cubit.load();

    await cubit.reject(orderById(1), reason: RejectReason.itemUnavailable);

    expect(repository.commands.single.reason, 'item_unavailable');
    expect(loaded().newOrders, isEmpty);
    expect(loaded().activeOrders.map((MerchantOrder o) => o.id), <int>[2, 3]);
  });
}
