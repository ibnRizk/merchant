import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/orders/domain/entities/merchant_order.dart';
import 'package:flutter_base/features/orders/domain/entities/order_status.dart';
import 'package:flutter_base/features/orders/presentation/cubit/orders_history/orders_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../orders_fakes.dart';

void main() {
  late FakeOrdersRepository repository;
  late OrdersHistoryCubit cubit;

  OrdersHistoryLoaded loaded() => cubit.state as OrdersHistoryLoaded;
  List<int> visibleIds() => <int>[
    for (final MerchantOrder o in loaded().visibleOrders) o.id,
  ];

  setUp(() {
    repository = FakeOrdersRepository();
    cubit = OrdersHistoryCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('the all tab combines current and completed orders', () async {
      await cubit.load();

      expect(visibleIds()..sort(), <int>[1, 2, 3, 10, 11]);
    });

    test('fails when either list fails', () async {
      repository.onGetCompleted = (_) async =>
          const Left(NetworkFailure(message: 'offline'));

      await cubit.load();

      expect((cubit.state as OrdersHistoryLoadFailure).message, 'offline');
    });
  });

  group('tabs', () {
    test('completed shows delivered orders', () async {
      await cubit.load();

      cubit.selectFilter(OrderFilter.completed);

      expect(visibleIds(), <int>[10]);
    });

    test('cancelled shows rejected orders', () async {
      await cubit.load();

      cubit.selectFilter(OrderFilter.cancelled);

      expect(visibleIds(), <int>[11]);
    });

    test('a tab chosen while loading applies to the loaded list', () async {
      final Future<void> loading = cubit.load();
      cubit.selectFilter(OrderFilter.completed);
      await loading;

      expect(visibleIds(), <int>[10]);
    });
  });

  test('search filters locally by order id', () async {
    await cubit.load();

    cubit.search(' #11 ');

    expect(visibleIds(), <int>[11]);
    expect(repository.currentRequests, 1);
  });

  group('loadMore', () {
    test('appends the next page', () async {
      repository.onGetCompleted = (int page) async => Right(
        historyPage(
          <MerchantOrder>[anOrder(100 + page, status: OrderStatus.delivered)],
          page: page,
          limit: 1,
          total: 2,
        ),
      );
      await cubit.load();

      await cubit.loadMore();

      expect(repository.completedRequests, <int>[1, 2]);
      expect(loaded().history.map((MerchantOrder o) => o.id), <int>[101, 102]);
      expect(loaded().hasMore, isFalse);
    });

    test('stops after a failure until retried', () async {
      repository.onGetCompleted = (int page) async => page == 1
          ? Right(historyPage(<MerchantOrder>[], limit: 1, total: 5))
          : const Left(NetworkFailure());
      await cubit.load();

      await cubit.loadMore();
      await cubit.loadMore();

      expect(repository.completedRequests, <int>[1, 2]);
      expect(loaded().loadMoreFailed, isTrue);
    });
  });

  test('a failed refresh keeps the list and announces it', () async {
    await cubit.load();
    repository.onGetCurrent = () async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.refresh();

    expect(visibleIds(), hasLength(5));
    expect((loaded().notice as OrderActionFailedNotice).message, 'offline');
  });
}
