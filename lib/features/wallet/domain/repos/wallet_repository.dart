import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/wallet.dart';

/// The store's wallet. Every route needs an approved account.
abstract class WalletRepository {
  Future<Either<Failure, WalletOverview>> getWallet();

  /// Asks the admin for a payout of [amount]; it is reserved in
  /// `pendingWithdraw` until settled. Asking for more than the available
  /// balance fails with the server's message (HTTP 422).
  Future<Either<Failure, Unit>> requestWithdrawal(double amount);
}
