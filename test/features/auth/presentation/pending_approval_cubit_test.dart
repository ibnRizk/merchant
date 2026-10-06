import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/entities/merchant_approval_status.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/utils/values/strings.dart';
import 'package:ssm_merchant/features/auth/domain/entities/onboarding_status.dart';
import 'package:ssm_merchant/features/auth/presentation/cubit/pending_approval/pending_approval_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_localizations.dart';
import '../auth_fakes.dart';

void main() {
  late FakeMerchantAuthRepository repository;
  late PendingApprovalCubit cubit;

  // A failure without a message falls back to a localized string.
  setUpAll(registerTestLocalizations);

  setUp(() {
    repository = FakeMerchantAuthRepository()
      ..onboardingResult = const Right(
        OnboardingStatus(status: MerchantApprovalStatus.pending),
      );
    cubit = PendingApprovalCubit(
      repository: repository,
      initialStatus: MerchantApprovalStatus.pending,
    );
  });

  tearDown(() => cubit.close());

  test('starts idle with the status it was opened with', () {
    expect(cubit.state.approvalStatus, MerchantApprovalStatus.pending);
    expect(cubit.state.status, PendingApprovalStatus.idle);
  });

  test('check reports approved once the account can operate', () async {
    repository.onboardingResult = const Right(
      OnboardingStatus(status: MerchantApprovalStatus.approved),
    );

    await cubit.check();

    expect(cubit.state.status, PendingApprovalStatus.approved);
  });

  test('check reports still restricted and updates the reason', () async {
    repository.onboardingResult = const Right(
      OnboardingStatus(
        status: MerchantApprovalStatus.rejected,
        rejectionReason: 'Missing documents',
      ),
    );

    await cubit.check();

    expect(cubit.state.status, PendingApprovalStatus.stillRestricted);
    expect(cubit.state.approvalStatus, MerchantApprovalStatus.rejected);
    expect(cubit.state.rejectionReason, 'Missing documents');
  });

  test('a silent check updates the status without announcing it', () async {
    repository.onboardingResult = const Right(
      OnboardingStatus(status: MerchantApprovalStatus.suspended),
    );

    await cubit.check(silent: true);

    expect(cubit.state.status, PendingApprovalStatus.idle);
    expect(cubit.state.approvalStatus, MerchantApprovalStatus.suspended);
  });

  test('a silent check still reports approval', () async {
    repository.onboardingResult = const Right(
      OnboardingStatus(status: MerchantApprovalStatus.approved),
    );

    await cubit.check(silent: true);

    expect(cubit.state.status, PendingApprovalStatus.approved);
  });

  test('a failed check shows the error unless silent', () async {
    repository.onboardingResult = const Left(
      NetworkFailure(message: 'offline'),
    );

    await cubit.check(silent: true);
    expect(cubit.state.status, PendingApprovalStatus.idle);

    await cubit.check();
    expect(cubit.state.status, PendingApprovalStatus.failure);
    expect(cubit.state.errorMessage, 'offline');
  });

  test('overlapping checks send one request', () async {
    await Future.wait(<Future<void>>[cubit.check(), cubit.check()]);

    expect(repository.onboardingCalls, 1);
  });

  test('signOut clears the session and reports it', () async {
    await cubit.signOut();

    expect(repository.clearSessionCalls, 1);
    expect(cubit.state.status, PendingApprovalStatus.signedOut);
  });

  test('a failed signOut reports the error', () async {
    repository.clearSessionResult = const Left(CacheFailure());

    await cubit.signOut();

    expect(cubit.state.status, PendingApprovalStatus.failure);
    expect(cubit.state.errorMessage, Strings.somethingWentWrong);
  });

  test('nothing runs after signing out', () async {
    await cubit.signOut();
    await cubit.check();

    expect(repository.onboardingCalls, 0);
  });
}
