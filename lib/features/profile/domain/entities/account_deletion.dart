import '../../../../core/error/failures.dart';

/// Why the server refused a deletion request (HTTP 409).
enum DeletionBlockReason {
  /// `active_orders_exist`: orders still in progress.
  activeOrders,

  /// `wallet_balance_not_settled`: money still owed either way.
  walletNotSettled,
}

/// The deletion request was refused for a reason the merchant can act on.
class AccountDeletionBlockedFailure extends Failure {
  @override
  final String? message;
  final DeletionBlockReason reason;

  const AccountDeletionBlockedFailure({required this.reason, this.message});

  @override
  List<Object?> get props => [message, reason];
}
