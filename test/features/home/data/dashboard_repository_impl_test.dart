import 'package:flutter_base/core/api/api_endpoints.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/home/data/datasources/dashboard_remote_data_source.dart';
import 'package:flutter_base/features/home/data/repos/dashboard_repository_impl.dart';
import 'package:flutter_base/features/home/domain/entities/dashboard_stats.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_dio_consumer.dart';
import 'dashboard_stats_model_test.dart' show response;

void main() {
  late FakeDioConsumer client;
  late DashboardRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer()..response = response();
    repository = DashboardRepositoryImpl(
      remote: DashboardRemoteDataSourceImpl(client: client),
    );
  });

  test('gets dashboard-stats', () async {
    await repository.getDashboardStats();

    expect(client.calls.single.verb, 'GET');
    expect(client.calls.single.path, ApiEndpoints.dashboardStats);
  });

  test('returns the parsed figures', () async {
    final result = await repository.getDashboardStats();

    expect(
      result.fold((_) => null, (DashboardStats s) => s.revenueToday),
      845.5,
    );
  });

  test('a malformed response is a server failure', () async {
    client.response = <dynamic>[];

    final result = await repository.getDashboardStats();

    expect(result.fold((Failure f) => f, (_) => null), isA<ServerFailure>());
  });

  test('maps an exception to its failure', () async {
    client.error = const InternetConnectionException(message: 'offline');

    final result = await repository.getDashboardStats();

    expect(
      result.fold((Failure f) => f, (_) => null),
      const NetworkFailure(message: 'offline'),
    );
  });
}
