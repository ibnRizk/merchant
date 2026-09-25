import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/orders/domain/entities/order_status.dart';
import 'package:flutter_base/features/orders/presentation/cubit/order_details/order_details_cubit.dart';
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
}
