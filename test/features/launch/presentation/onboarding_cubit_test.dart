import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/launch/presentation/cubit/onboarding/onboarding_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../launch_fakes.dart';

void main() {
  late FakeLaunchRepository repository;
  late OnboardingCubit cubit;

  setUp(() {
    repository = FakeLaunchRepository();
    cubit = OnboardingCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('starts in progress', () {
    expect(cubit.state, isA<OnboardingInProgress>());
  });

  test('complete saves the seen flag and completes', () async {
    await cubit.complete();

    expect(cubit.state, isA<OnboardingCompleted>());
    expect(repository.markSeenCalls, 1);
  });

  test('completes even when saving the flag fails', () async {
    repository.markSeenResult = const Left(CacheFailure());

    await cubit.complete();

    expect(cubit.state, isA<OnboardingCompleted>());
  });

  test('a second complete does not save again', () async {
    await cubit.complete();
    await cubit.complete();

    expect(repository.markSeenCalls, 1);
  });
}
