import 'package:equatable/equatable.dart';

/// The store's money, as `GET /vendor/wallet` reports it. All amounts are
/// in the store currency.
class WalletBalance extends Equatable {
  final double totalEarning;
  final double totalWithdrawn;

  /// Reserved by withdrawal requests the admin hasn't settled yet.
  final double pendingWithdraw;

  /// Cash the store collected from customers on delivery.
  final double collectedCash;

  /// What can be withdrawn now: earnings minus withdrawn, pending and
  /// collected cash. Computed by the server.
  final double availableBalance;

  const WalletBalance({
    required this.totalEarning,
    required this.totalWithdrawn,
    required this.pendingWithdraw,
    required this.collectedCash,
    required this.availableBalance,
  });

  /// Why [amount] can't be requested, or `null` when it can.
  WithdrawAmountError? validateWithdrawal(double? amount) {
    if (amount == null) return WithdrawAmountError.invalid;
    if (amount < minimumWithdrawal) return WithdrawAmountError.belowMinimum;
    if (amount > availableBalance) return WithdrawAmountError.aboveBalance;
    return null;
  }

  /// The API rejects anything below this (`amount >= 1`).
  static const double minimumWithdrawal = 1;

  @override
  List<Object?> get props => [
    totalEarning,
    totalWithdrawn,
    pendingWithdraw,
    collectedCash,
    availableBalance,
  ];
}

enum WithdrawAmountError { invalid, belowMinimum, aboveBalance }

enum WithdrawStatus { pending, approved, denied, unknown }

/// A payout the merchant asked for.
class WithdrawRequest extends Equatable {
  final int id;
  final double amount;
  final WithdrawStatus status;
  final DateTime? createdAt;

  const WithdrawRequest({
    required this.id,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, amount, status, createdAt];
}

/// The wallet screen's data: balances and the latest payout requests.
class WalletOverview extends Equatable {
  final WalletBalance balance;

  /// Newest first, as the API sends them (first page only).
  final List<WithdrawRequest> withdrawals;

  const WalletOverview({required this.balance, required this.withdrawals});

  @override
  List<Object?> get props => [balance, withdrawals];
}
