import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard_failure.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repos/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remote;

  const WalletRepositoryImpl({required WalletRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Either<Failure, WalletOverview>> getWallet() =>
      guardFailure<WalletOverview>(_remote.getWallet);

  @override
  Future<Either<Failure, Unit>> requestWithdrawal(double amount) =>
      guardFailure(() async {
        await _remote.requestWithdrawal(amount);
        return unit;
      });
}
