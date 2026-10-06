import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/home/domain/entities/store_analytics.dart';
import 'package:ssm_merchant/features/home/domain/repos/analytics_repository.dart';
import 'package:ssm_merchant/features/home/presentation/cubit/analytics/analytics_cubit.dart';

const StoreAnalytics sample = StoreAnalytics(
  totalOrders: 4,
  deliveredOrders: 3,
  cancelledOrders: 1,
  totalSales: 200,
  averageOrderValue: 50,
);

class FakeAnalyticsRepository implements AnalyticsRepository {
  Either<Failure, StoreAnalytics> result = const Right(sample);
  final List<({DateTime from, DateTime to})> requests = [];

  @override
  Future<Either<Failure, StoreAnalytics>> getAnalytics({
    required DateTime from,
    required DateTime to,
  }) async {
    requests.add((from: from, to: to));
    return result;
  }
}

void main() {
  late FakeAnalyticsRepository repository;
  late AnalyticsCubit cubit;

  setUp(() {
    repository = FakeAnalyticsRepository();
    cubit = AnalyticsCubit(
      repository: repository,
      now: () => DateTime(2026, 3, 31, 9),
    );
  });

  tearDown(() => cubit.close());

  test('load fetches the last 7 days by default', () async {
    await cubit.load();

    expect(cubit.state, isA<AnalyticsLoaded>());
    expect(repository.requests.single.from, DateTime(2026, 3, 25));
    expect(repository.requests.single.to, DateTime(2026, 3, 31));
  });

  test('selecting a period refetches that range', () async {
    await cubit.load();

    await cubit.selectPeriod(AnalyticsPeriod.last30Days);

    expect(cubit.state.period, AnalyticsPeriod.last30Days);
    expect(repository.requests.last.from, DateTime(2026, 3, 2));
  });

  test('a failed load keeps the selected period', () async {
    repository.result = const Left(NetworkFailure(message: 'offline'));

    await cubit.selectPeriod(AnalyticsPeriod.last90Days);

    final AnalyticsLoadFailure state = cubit.state as AnalyticsLoadFailure;
    expect(state.period, AnalyticsPeriod.last90Days);
    expect(state.message, 'offline');
  });

  test('a failed refresh keeps the figures on screen', () async {
    await cubit.load();
    repository.result = const Left(NetworkFailure(message: 'offline'));

    await cubit.refresh();

    expect((cubit.state as AnalyticsLoaded).analytics, sample);
  });
}
