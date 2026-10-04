import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/services/local_storage/app_shared_preferences.dart';
import 'package:ssm_merchant/features/app_config/data/datasources/app_config_remote_data_source.dart';
import 'package:ssm_merchant/features/app_config/data/repos/app_config_repository_impl.dart';
import 'package:ssm_merchant/features/app_config/domain/entities/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/fake_dio_consumer.dart';

const Map<String, dynamic> _configBody = <String, dynamic>{
  'support': <String, dynamic>{'email': 'help@ssm.test'},
  'legal': <String, dynamic>{},
  'application': <String, dynamic>{'currency': 'EGP'},
};

void main() {
  late FakeDioConsumer client;
  late AppSharedPreferences preferences;
  late AppConfigRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = AppSharedPreferencesImpl(
      instance: await SharedPreferences.getInstance(),
    );
    client = FakeDioConsumer();
    repository = AppConfigRepositoryImpl(
      remote: AppConfigRemoteDataSourceImpl(client: client),
      preferences: preferences,
    );
  });

  test('the cache is empty before the first fetch', () {
    expect(repository.cachedConfig(), AppConfig.empty);
  });

  test('fetchConfig GETs /vendor/config and caches the result', () async {
    client.response = _configBody;

    final result = await repository.fetchConfig();

    expect(client.calls.single.verb, 'GET');
    expect(client.calls.single.path, ApiEndpoints.vendorConfig);
    expect(result.getOrElse(() => AppConfig.empty).currency, 'EGP');
    expect(repository.cachedConfig().currency, 'EGP');
    expect(repository.cachedConfig().supportEmail, 'help@ssm.test');
  });

  test('a failed fetch keeps the previous cache', () async {
    client.response = _configBody;
    await repository.fetchConfig();
    client.error = const InternetConnectionException(message: 'offline');

    final result = await repository.fetchConfig();

    expect(
      result.swap().getOrElse(() => throw 'no failure'),
      const NetworkFailure(message: 'offline'),
    );
    expect(repository.cachedConfig().currency, 'EGP');
  });

  test('a malformed body never replaces a good cache', () async {
    client.response = _configBody;
    await repository.fetchConfig();
    client.response = <String, dynamic>{'message': 'not a config'};

    final result = await repository.fetchConfig();

    expect(result.isLeft(), isTrue);
    expect(repository.cachedConfig().currency, 'EGP');
  });

  test('an unreadable cache counts as empty', () async {
    await preferences.saveAppConfig(<String, dynamic>{'legacy': true});

    expect(repository.cachedConfig(), AppConfig.empty);
  });
}
