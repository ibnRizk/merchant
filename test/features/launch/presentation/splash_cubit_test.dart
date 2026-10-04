import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/entities/merchant_approval_status.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/auth/domain/entities/onboarding_status.dart';
import 'package:ssm_merchant/features/launch/domain/entities/launch_destination.dart';
import 'package:ssm_merchant/features/launch/presentation/cubit/splash/splash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../auth/auth_fakes.dart';
import '../launch_fakes.dart';

void main() {
  late FakeLaunchRepository repository;
  late FakeMerchantAuthRepository authRepository;
  late SplashCubit cubit;

  setUp(() {
    repository = FakeLaunchRepository();
    authRepository = FakeMerchantAuthRepository();
    cubit = SplashCubit(
      repository: repository,
      authRepository: authRepository,
      minDisplay: Duration.zero,
    );
  });

  tearDown(() => cubit.close());

  SplashResolved resolved() => cubit.state as SplashResolved;

  test('starts loading', () {
    expect(cubit.state, isA<SplashLoading>());
  });

  group('with a saved session', () {
    setUp(() => repository.sessionResult = const Right(true));

    test('goes to home when the account can operate', () async {
      await cubit.start();

      expect(resolved().destination, LaunchDestination.home);
      expect(authRepository.onboardingCalls, 1);
    });

    // Regression (audit C-03): a pending login saves a token too, and the
    // splash used to send it straight to a home screen full of 403s.
    test('goes to the pending screen when the account is pending', () async {
      authRepository.onboardingResult = const Right(
        OnboardingStatus(status: MerchantApprovalStatus.pending),
      );

      await cubit.start();

      expect(resolved().destination, LaunchDestination.pendingApproval);
      expect(resolved().approvalStatus, MerchantApprovalStatus.pending);
    });

    test('passes a rejected or suspended status on', () async {
      authRepository.onboardingResult = const Right(
        OnboardingStatus(status: MerchantApprovalStatus.suspended),
      );

      await cubit.start();

      expect(resolved().destination, LaunchDestination.pendingApproval);
      expect(resolved().approvalStatus, MerchantApprovalStatus.suspended);
    });

    test('goes to login when the token was revoked', () async {
      authRepository.onboardingResult = const Left(UnauthorizedFailure());

      await cubit.start();

      expect(resolved().destination, LaunchDestination.login);
    });

    test('goes to home when the status cannot be checked offline', () async {
      authRepository.onboardingResult = const Left(NetworkFailure());

      await cubit.start();

      expect(resolved().destination, LaunchDestination.home);
    });

    test('a 403 restriction routes to the pending screen', () async {
      authRepository.onboardingResult = const Left(
        AccountRestrictedFailure(status: MerchantApprovalStatus.rejected),
      );

      await cubit.start();

      expect(resolved().destination, LaunchDestination.pendingApproval);
      expect(resolved().approvalStatus, MerchantApprovalStatus.rejected);
    });

    test('skips onboarding even if it was never seen', () async {
      repository.seenResult = const Right(false);

      await cubit.start();

      expect(resolved().destination, LaunchDestination.home);
    });
  });

  test('goes to onboarding on first launch', () async {
    await cubit.start();

    expect(resolved().destination, LaunchDestination.onboarding);
    expect(authRepository.onboardingCalls, 0);
  });

  test(
    'goes to login when onboarding was seen and there is no session',
    () async {
      repository.seenResult = const Right(true);

      await cubit.start();

      expect(resolved().destination, LaunchDestination.login);
    },
  );

  test('treats an unreadable session as logged out', () async {
    repository
      ..sessionResult = const Left(CacheFailure())
      ..seenResult = const Right(true);

    await cubit.start();

    expect(resolved().destination, LaunchDestination.login);
  });

  test('shows onboarding when its flag cannot be read', () async {
    repository.seenResult = const Left(CacheFailure());

    await cubit.start();

    expect(resolved().destination, LaunchDestination.onboarding);
  });
}
