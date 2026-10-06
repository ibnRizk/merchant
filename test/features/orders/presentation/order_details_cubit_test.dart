import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/orders/domain/entities/order_status.dart';
import 'package:ssm_merchant/features/orders/domain/order_failures.dart';
import 'package:ssm_merchant/features/orders/domain/params/order_command.dart';
import 'package:ssm_merchant/features/orders/presentation/cubit/order_details/order_details_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late OrderDetailsCubit cubit;

  OrderDetailsLoaded loaded() => cubit.state as OrderDetailsLoaded;

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = OrderDetailsCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load shows the summary and its lines', () async {
    await cubit.load(1);

    expect(loaded().order.status, OrderStatus.accepted);
    expect(loaded().lines.single.name, 'Burger');
  });

  test('load fails when the lines fail', () async {
    repository.linesResult = const Left(ServerFailure(message: 'boom'));

    await cubit.load(1);

    expect((cubit.state as OrderDetailsLoadFailure).message, 'boom');
  });

  test('advance moves the order to its next status', () async {
    await cubit.load(1);

    await cubit.advance();

    expect(loaded().order.status, OrderStatus.preparing);
    expect(loaded().order.statusVersion, 2);
    expect(loaded().isBusy, isFalse);
  });

  test('a conflict announces it and reloads the order', () async {
    await cubit.load(1);
    repository.onSendCommand = (_) async => const Left(ConflictFailure());
    repository.orderResult = Right(anOrder(1, status: OrderStatus.preparing));
    final Future<OrderDetailsState> reloaded = cubit.stream.firstWhere(
      (OrderDetailsState s) =>
          s is OrderDetailsLoaded && s.order.status == OrderStatus.preparing,
    );

    await cubit.advance();

    expect(loaded().notice, isA<OrderConflictNotice>());
    await reloaded;
  });

  group('cancel', () {
    test('sends the reason, note and version of an accepted order', () async {
      await cubit.load(1);
      final int? version = loaded().order.statusVersion;

      await cubit.cancel(reason: CancelReason.itemUnavailable, note: 'no buns');

      expect(
        repository.commands.single,
        OrderCommand.cancel(
          orderId: 1,
          reason: CancelReason.itemUnavailable,
          note: 'no buns',
          expectedVersion: version,
        ),
      );
    });

    test('a cancelled order shows as cancelled', () async {
      await cubit.load(1);

      await cubit.cancel(reason: CancelReason.customerRequest);

      expect(loaded().order.status, OrderStatus.cancelled);
      expect(loaded().notice, isA<OrderUpdatedNotice>());
    });

    test('is allowed while preparing', () async {
      repository.orderResult = Right(anOrder(1, status: OrderStatus.preparing));
      await cubit.load(1);

      await cubit.cancel(reason: CancelReason.storeClosing);

      expect(repository.commands, hasLength(1));
    });

    test('is not sent once the order is ready for pickup', () async {
      repository.orderResult = Right(
        anOrder(1, status: OrderStatus.readyForPickup),
      );
      await cubit.load(1);

      await cubit.cancel(reason: CancelReason.other);

      expect(repository.commands, isEmpty);
    });

    test('a refused transition reloads the order', () async {
      await cubit.load(1);
      repository.onSendCommand = (_) async =>
          const Left(TransitionRejectedFailure());
      repository.orderResult = Right(anOrder(1, status: OrderStatus.cancelled));
      final Future<OrderDetailsState> reloaded = cubit.stream.firstWhere(
        (OrderDetailsState s) =>
            s is OrderDetailsLoaded && s.order.status == OrderStatus.cancelled,
      );

      await cubit.cancel(reason: CancelReason.other);

      expect(loaded().notice, isA<OrderConflictNotice>());
      await reloaded;
    });
  });

  group('retry dispatch', () {
    setUp(
      () => repository.orderResult = Right(
        anOrder(1, status: OrderStatus.assignmentFailed),
      ),
    );

    test('sends the retry for the open order', () async {
      await cubit.load(1);

      await cubit.retryDispatch();

      expect(repository.retriedDispatches, <int>[1]);
    });

    test('announces the retry, then shows the re-read status', () async {
      await cubit.load(1);
      repository.orderResult = Right(
        anOrder(1, status: OrderStatus.dispatching),
      );
      final Future<void> announced = expectLater(
        cubit.stream,
        emitsThrough(
          isA<OrderDetailsLoaded>().having(
            (OrderDetailsLoaded s) => s.notice,
            'notice',
            isA<OrderDispatchRetriedNotice>(),
          ),
        ),
      );

      await cubit.retryDispatch();

      await announced;
      expect(loaded().order.status, OrderStatus.dispatching);
      expect(loaded().isBusy, isFalse);
    });

    test('a failure is reported and the button comes back', () async {
      await cubit.load(1);
      repository.retryDispatchResult = const Left(
        ServerFailure(message: 'dispatch unavailable'),
      );
      final Future<void> reported = expectLater(
        cubit.stream,
        emitsThrough(
          isA<OrderDetailsLoaded>().having(
            (OrderDetailsLoaded s) => s.notice,
            'notice',
            isA<OrderActionFailedNotice>(),
          ),
        ),
      );

      await cubit.retryDispatch();

      await reported;
      expect(loaded().isBusy, isFalse);
      expect(loaded().order.status, OrderStatus.assignmentFailed);
    });

    test('a stale order is announced and re-read', () async {
      await cubit.load(1);
      repository.retryDispatchResult = const Left(TransitionRejectedFailure());
      repository.orderResult = Right(
        anOrder(1, status: OrderStatus.driverAccepted),
      );

      await cubit.retryDispatch();

      expect(loaded().order.status, OrderStatus.driverAccepted);
    });

    test('is not sent for an order that has a driver search going', () async {
      repository.orderResult = Right(
        anOrder(1, status: OrderStatus.dispatching),
      );
      await cubit.load(1);

      await cubit.retryDispatch();

      expect(repository.retriedDispatches, isEmpty);
    });

    test('a second tap while one is on its way is ignored', () async {
      await cubit.load(1);

      final Future<void> first = cubit.retryDispatch();
      await cubit.retryDispatch();
      await first;

      expect(repository.retriedDispatches, <int>[1]);
    });
  });
}
