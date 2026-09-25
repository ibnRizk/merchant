import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/home/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:flutter_base/features/orders/domain/entities/merchant_order.dart';
import 'package:flutter_base/features/orders/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../orders/orders_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late DashboardCubit cubit;

  DashboardLoaded loaded() => cubit.state as DashboardLoaded;

  setUp(() {
    repository = FakeOrdersRepository();
    repository.onGetCurrent = () async => Right(<MerchantOrder>[
      anOrder(1, createdAt: DateTime(2026, 9, 25, 9)),
      anOrder(
        2,
        status: OrderStatus.preparing,
        createdAt: DateTime(2026, 9, 25, 9),
      ),
    ]);
    repository.onGetCompleted = (_) async => Right(
      historyPage(<MerchantOrder>[
        anOrder(
          3,
          status: OrderStatus.delivered,
          createdAt: DateTime(2026, 9, 25, 8),
        ),
      ]),
    );
    cubit = DashboardCubit(
      repository: repository,
      now: () => DateTime(2026, 9, 25, 15),
    );
  });

  tearDown(() => cubit.close());

  test('load computes the figures from both order lists', () async {
    await cubit.load();

    expect(loaded().stats.newOrders, 1);
    expect(loaded().stats.processingOrders, 1);
    expect(loaded().stats.ordersToday, 3);
    expect(loaded().stats.revenueToday, 50);
  });

  test('load fails when the completed orders fail', () async {
    repository.onGetCompleted = (_) async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.load();

    expect((cubit.state as DashboardLoadFailure).message, 'offline');
  });

  test('a failed refresh keeps the figures and reports it', () async {
    await cubit.load();
    repository.onGetCurrent = () async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.refresh();

    expect(loaded().stats.newOrders, 1);
    expect(loaded().refreshFailure?.message, 'offline');
  });
}
