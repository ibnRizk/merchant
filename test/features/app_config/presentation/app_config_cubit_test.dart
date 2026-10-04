import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/app_config/domain/entities/app_config.dart';
import 'package:ssm_merchant/features/app_config/domain/repos/app_config_repository.dart';
import 'package:ssm_merchant/features/app_config/presentation/cubit/app_config_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAppConfigRepository implements AppConfigRepository {
  AppConfig cached = AppConfig.empty;
  Either<Failure, AppConfig> fetchResult = const Right(AppConfig.empty);
  int fetchCalls = 0;

  @override
  AppConfig cachedConfig() => cached;

  @override
  Future<Either<Failure, AppConfig>> fetchConfig() async {
    fetchCalls++;
    return fetchResult;
  }
}

void main() {
  late _FakeAppConfigRepository repository;

  setUp(() => repository = _FakeAppConfigRepository());

  test('starts from the cached config', () {
    repository.cached = const AppConfig(currency: 'EGP');

    final AppConfigCubit cubit = AppConfigCubit(repository: repository);
    addTearDown(cubit.close);

    expect(cubit.state.currency, 'EGP');
    expect(repository.fetchCalls, 0);
  });

  test('refresh emits the fetched config', () async {
    repository.fetchResult = const Right(AppConfig(currency: 'ج.م'));
    final AppConfigCubit cubit = AppConfigCubit(repository: repository);
    addTearDown(cubit.close);

    await cubit.refresh();

    expect(cubit.state.currency, 'ج.م');
  });

  test('a failed refresh keeps the current config', () async {
    repository
      ..cached = const AppConfig(currency: 'EGP')
      ..fetchResult = const Left(NetworkFailure());
    final AppConfigCubit cubit = AppConfigCubit(repository: repository);
    addTearDown(cubit.close);

    await cubit.refresh();

    expect(cubit.state.currency, 'EGP');
  });

  test('overlapping refreshes send one request', () async {
    final AppConfigCubit cubit = AppConfigCubit(repository: repository);
    addTearDown(cubit.close);

    await Future.wait(<Future<void>>[cubit.refresh(), cubit.refresh()]);

    expect(repository.fetchCalls, 1);
  });
}
