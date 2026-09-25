import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/launch/domain/entities/launch_destination.dart';
import 'package:ssm_merchant/features/launch/presentation/cubit/splash/splash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../launch_fakes.dart';

void main() {
  late FakeLaunchRepository repository;
  late SplashCubit cubit;

  setUp(() {
    repository = FakeLaunchRepository();
    cubit = SplashCubit(repository: repository, minDisplay: Duration.zero);
  });

  tearDown(() => cubit.close());

  LaunchDestination? destinationOf(SplashState state) =>
      state is SplashResolved ? state.destination : null;

  test('starts loading', () {
    expect(cubit.state, isA<SplashLoading>());
  });

  test('goes to home when a session is saved', () async {
    repository.sessionResult = const Right(true);

    await cubit.start();

    expect(destinationOf(cubit.state), LaunchDestination.home);
  });

  test('a saved session skips onboarding even if it was never seen', () async {
    repository
      ..sessionResult = const Right(true)
      ..seenResult = const Right(false);

    await cubit.start();

    expect(destinationOf(cubit.state), LaunchDestination.home);
  });

  test('goes to onboarding on first launch', () async {
    await cubit.start();

    expect(destinationOf(cubit.state), LaunchDestination.onboarding);
  });

  test(
    'goes to login when onboarding was seen and there is no session',
    () async {
      repository.seenResult = const Right(true);

      await cubit.start();

      expect(destinationOf(cubit.state), LaunchDestination.login);
    },
  );

  test('treats an unreadable session as logged out', () async {
    repository
      ..sessionResult = const Left(CacheFailure())
      ..seenResult = const Right(true);

    await cubit.start();

    expect(destinationOf(cubit.state), LaunchDestination.login);
  });

  test('shows onboarding when its flag cannot be read', () async {
    repository.seenResult = const Left(CacheFailure());

    await cubit.start();

    expect(destinationOf(cubit.state), LaunchDestination.onboarding);
  });
}
