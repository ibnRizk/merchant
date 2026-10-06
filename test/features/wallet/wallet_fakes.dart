import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/wallet/domain/entities/wallet.dart';
import 'package:ssm_merchant/features/wallet/domain/repos/wallet_repository.dart';

export '../../helpers/fake_dio_consumer.dart';

WalletBalance balanceOf(double available) => WalletBalance(
  totalEarning: available + 50,
  totalWithdrawn: 50,
  pendingWithdraw: 0,
  collectedCash: 0,
  availableBalance: available,
);

WalletOverview overviewOf(double available) =>
    WalletOverview(balance: balanceOf(available), withdrawals: const []);

class FakeWalletRepository implements WalletRepository {
  Either<Failure, WalletOverview> walletResult = Right(overviewOf(100));
  Future<Either<Failure, Unit>> Function(double amount) onWithdraw =
      (_) async => const Right(unit);

  int walletCalls = 0;
  final List<double> withdrawals = <double>[];

  @override
  Future<Either<Failure, WalletOverview>> getWallet() async {
    walletCalls++;
    return walletResult;
  }

  @override
  Future<Either<Failure, Unit>> requestWithdrawal(double amount) {
    withdrawals.add(amount);
    return onWithdraw(amount);
  }
}
