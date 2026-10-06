import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/home/domain/entities/dashboard_stats.dart';
import 'package:ssm_merchant/features/home/domain/repos/dashboard_repository.dart';
import 'package:ssm_merchant/features/home/presentation/cubit/dashboard/dashboard_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const DashboardStats figures = DashboardStats(
  ordersToday: 12,
  newOrders: 3,
  processingOrders: 2,
  revenueToday: 845.5,
);

class FakeDashboardRepository implements DashboardRepository {
  Future<Either<Failure, DashboardStats>> Function() onGet = () async =>
      const Right(figures);

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() => onGet();
}

void main() {
  late FakeDashboardRepository repository;
  late DashboardCubit cubit;

  DashboardLoaded loaded() => cubit.state as DashboardLoaded;

  setUp(() {
    repository = FakeDashboardRepository();
    cubit = DashboardCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load shows the server figures as they are', () async {
    await cubit.load();

    expect(loaded().stats, figures);
  });

  test('load reports a failure', () async {
    repository.onGet = () async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.load();

    expect((cubit.state as DashboardLoadFailure).message, 'offline');
  });

  test('a failed refresh keeps the figures and reports it', () async {
    await cubit.load();
    repository.onGet = () async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.refresh();

    expect(loaded().stats, figures);
    expect(loaded().refreshFailure?.message, 'offline');
  });

  group('poll', () {
    test('updates the figures', () async {
      await cubit.load();
      repository.onGet = () async => const Right(DashboardStats.empty);

      await cubit.poll();

      expect(loaded().stats, DashboardStats.empty);
    });

    test('a failure keeps the figures without reporting it', () async {
      await cubit.load();
      final DashboardState before = cubit.state;
      repository.onGet = () async =>
          const Left(NetworkFailure(message: 'offline'));

      await cubit.poll();

      expect(cubit.state, same(before));
    });

    test('a success recovers from a failed first load', () async {
      repository.onGet = () async =>
          const Left(NetworkFailure(message: 'offline'));
      await cubit.load();
      repository.onGet = () async => const Right(figures);

      await cubit.poll();

      expect(loaded().stats, figures);
    });

    test('a failure leaves a failed first load as it is', () async {
      repository.onGet = () async =>
          const Left(NetworkFailure(message: 'offline'));
      await cubit.load();
      final DashboardState before = cubit.state;

      await cubit.poll();

      expect(cubit.state, same(before));
    });
  });

  test('an older response does not overwrite a newer one', () async {
    final Completer<Either<Failure, DashboardStats>> slow = Completer();
    repository.onGet = () => slow.future;
    final Future<void> first = cubit.load();

    repository.onGet = () async => const Right(DashboardStats.empty);
    await cubit.load();
    slow.complete(const Right(figures));
    await first;

    expect(loaded().stats, DashboardStats.empty);
  });
}
