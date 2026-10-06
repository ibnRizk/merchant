import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/wallet/presentation/cubit/wallet_cubit.dart';

import '../wallet_fakes.dart';

void main() {
  late FakeWalletRepository repository;
  late WalletCubit cubit;

  WalletLoaded loaded() => cubit.state as WalletLoaded;

  setUp(() {
    repository = FakeWalletRepository();
    cubit = WalletCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('load shows the wallet', () async {
    await cubit.load();

    expect(loaded().overview.balance.availableBalance, 100);
  });

  test('a failed load shows the message', () async {
    repository.walletResult = const Left(NetworkFailure(message: 'offline'));

    await cubit.load();

    expect((cubit.state as WalletLoadFailure).message, 'offline');
  });

  test('a payout request announces it and reloads the wallet', () async {
    await cubit.load();
    repository.walletResult = Right(overviewOf(60));

    await cubit.requestWithdrawal(40);
    await Future<void>.delayed(Duration.zero);

    expect(repository.withdrawals, <double>[40]);
    expect(repository.walletCalls, 2);
    expect(loaded().overview.balance.availableBalance, 60);
    expect(loaded().isSubmitting, isFalse);
  });

  test('a refused payout shows the server message', () async {
    await cubit.load();
    repository.onWithdraw = (_) async =>
        const Left(ServerFailure(message: 'Insufficient balance.'));

    await cubit.requestWithdrawal(40);

    expect(
      (loaded().notice as WalletFailureNotice).message,
      'Insufficient balance.',
    );
    expect(loaded().isSubmitting, isFalse);
  });

  test('an amount above the balance is not sent', () async {
    await cubit.load();

    await cubit.requestWithdrawal(1000);

    expect(repository.withdrawals, isEmpty);
  });

  test('a second request while one is in flight is ignored', () async {
    await cubit.load();
    final Completer<Either<Failure, Unit>> pending = Completer();
    repository.onWithdraw = (_) => pending.future;

    final Future<void> first = cubit.requestWithdrawal(10);
    await cubit.requestWithdrawal(10);
    pending.complete(const Right(unit));
    await first;

    expect(repository.withdrawals, hasLength(1));
  });
}
