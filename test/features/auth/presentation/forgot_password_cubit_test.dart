import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/auth/presentation/cubit/forgot_password/forgot_password_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth_fakes.dart';

void main() {
  late FakeMerchantAuthRepository repository;
  late ForgotPasswordCubit cubit;

  setUp(() {
    repository = FakeMerchantAuthRepository();
    cubit = ForgotPasswordCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  Future<void> reachResetStep() async {
    await cubit.requestOtp('sara@example.com');
    await cubit.verifyOtp('1234');
  }

  test('starts on the request step', () {
    expect(cubit.state.step, ForgotPasswordStep.requestOtp);
    expect(cubit.state.status, ForgotPasswordStatus.idle);
  });

  test('requestOtp trims the email and moves to verification', () async {
    await cubit.requestOtp('  sara@example.com ');

    expect(repository.forgotPasswordEmails, <String>['sara@example.com']);
    expect(cubit.state.step, ForgotPasswordStep.verifyOtp);
    expect(cubit.state.email, 'sara@example.com');
  });

  test('a failed request stays on the step with the message', () async {
    repository.forgotPasswordResult = const Left(
      ServerFailure(message: 'Too many attempts'),
    );

    await cubit.requestOtp('sara@example.com');

    expect(cubit.state.step, ForgotPasswordStep.requestOtp);
    expect(cubit.state.status, ForgotPasswordStatus.failure);
    expect(cubit.state.errorMessage, 'Too many attempts');
  });

  test('resendOtp sends to the same email and says so', () async {
    await cubit.requestOtp('sara@example.com');

    await cubit.resendOtp();

    expect(repository.forgotPasswordEmails, <String>[
      'sara@example.com',
      'sara@example.com',
    ]);
    expect(cubit.state.status, ForgotPasswordStatus.otpResent);
    expect(cubit.state.step, ForgotPasswordStep.verifyOtp);
  });

  test('verifyOtp checks the code for that email', () async {
    await reachResetStep();

    expect(repository.verifyCalls.single.email, 'sara@example.com');
    expect(repository.verifyCalls.single.resetToken, '1234');
    expect(cubit.state.step, ForgotPasswordStep.resetPassword);
  });

  test('a wrong code stays on verification', () async {
    await cubit.requestOtp('sara@example.com');
    repository.verifyTokenResult = const Left(
      ServerFailure(message: 'Invalid code'),
    );

    await cubit.verifyOtp('0000');

    expect(cubit.state.step, ForgotPasswordStep.verifyOtp);
    expect(cubit.state.errorMessage, 'Invalid code');
  });

  test('resetPassword sends the verified code and completes', () async {
    await reachResetStep();

    await cubit.resetPassword(
      password: 'Strong#123',
      confirmPassword: 'Strong#123',
    );

    final reset = repository.resetCalls.single;
    expect(reset.email, 'sara@example.com');
    expect(reset.resetToken, '1234');
    expect(reset.password, 'Strong#123');
    expect(reset.confirmPassword, 'Strong#123');
    expect(cubit.state.status, ForgotPasswordStatus.completed);
  });

  test('back walks the steps and keeps the email', () async {
    await reachResetStep();

    expect(cubit.back(), isTrue);
    expect(cubit.state.step, ForgotPasswordStep.verifyOtp);
    expect(cubit.back(), isTrue);
    expect(cubit.state.step, ForgotPasswordStep.requestOtp);
    expect(cubit.state.email, 'sara@example.com');
    expect(cubit.back(), isFalse);
  });
}
