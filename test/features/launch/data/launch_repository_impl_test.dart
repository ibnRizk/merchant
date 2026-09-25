import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/services/local_storage/app_shared_preferences.dart';
import 'package:ssm_merchant/features/launch/data/repos/launch_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../launch_fakes.dart';

void main() {
  late AppSharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = AppSharedPreferencesImpl(
      instance: await SharedPreferences.getInstance(),
    );
  });

  LaunchRepositoryImpl repositoryWith(FakeSecureStorage storage) =>
      LaunchRepositoryImpl(preferences: preferences, secureStorage: storage);

  test('hasSession is true when a token is saved', () async {
    final result = await repositoryWith(
      FakeSecureStorage(accessToken: 'token'),
    ).hasSession();

    expect(result, const Right<Failure, bool>(true));
  });

  test('hasSession is false when no token is saved', () async {
    final result = await repositoryWith(FakeSecureStorage()).hasSession();

    expect(result, const Right<Failure, bool>(false));
  });

  test('hasSession is false for an empty token', () async {
    final result = await repositoryWith(
      FakeSecureStorage(accessToken: ''),
    ).hasSession();

    expect(result, const Right<Failure, bool>(false));
  });

  test('hasSession maps a storage error to CacheFailure', () async {
    final result = await repositoryWith(ThrowingSecureStorage()).hasSession();

    expect(result, const Left<Failure, bool>(CacheFailure()));
  });

  test('onboarding is not seen on a fresh install', () async {
    final result = await repositoryWith(
      FakeSecureStorage(),
    ).hasSeenOnboarding();

    expect(result, const Right<Failure, bool>(false));
  });

  test('markOnboardingSeen is remembered', () async {
    final LaunchRepositoryImpl repository = repositoryWith(FakeSecureStorage());

    await repository.markOnboardingSeen();

    expect(
      await repository.hasSeenOnboarding(),
      const Right<Failure, bool>(true),
    );
  });
}
