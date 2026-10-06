import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';
import '../../domain/entities/wallet.dart';

/// `GET /vendor/wallet`: `{wallet: {total_earning, total_withdrawn,
/// pending_withdraw, collected_cash, available_balance}, withdraw_requests}`
/// where `withdraw_requests` is a Laravel paginator (or a bare list).
class WalletOverviewModel extends WalletOverview {
  const WalletOverviewModel({
    required super.balance,
    required super.withdrawals,
  });

  /// Throws [UnexpectedResponseException] when the balances are missing: a
  /// default zero would read as the real balance.
  factory WalletOverviewModel.fromJson(Map<String, dynamic> json) {
    final dynamic wallet = json['wallet'];
    if (wallet is! Map<String, dynamic>) {
      throw const UnexpectedResponseException();
    }
    return WalletOverviewModel(
      balance: WalletBalance(
        totalEarning: _amount(wallet['total_earning']),
        totalWithdrawn: _amount(wallet['total_withdrawn']),
        pendingWithdraw: _amount(wallet['pending_withdraw']),
        collectedCash: _amount(wallet['collected_cash']),
        availableBalance: _amount(wallet['available_balance']),
      ),
      withdrawals: <WithdrawRequest>[
        for (final Map<String, dynamic> item in jsonMaps(
          json['withdraw_requests'],
        ))
          WithdrawRequestModel.fromJson(item),
      ],
    );
  }

  static double _amount(dynamic value) {
    final double? amount = double.tryParse('$value');
    if (amount != null) return amount;
    throw const UnexpectedResponseException();
  }
}

class WithdrawRequestModel extends WithdrawRequest {
  const WithdrawRequestModel({
    required super.id,
    required super.amount,
    required super.status,
    super.createdAt,
  });

  factory WithdrawRequestModel.fromJson(Map<String, dynamic> json) =>
      WithdrawRequestModel(
        id: jsonInt(json['id']),
        amount: jsonDouble(json['amount']),
        status: _status(json),
        createdAt: DateTime.tryParse(jsonText(json['created_at']))?.toLocal(),
      );

  /// `status` as text; older payloads use `approved` (0 pending,
  /// 1 approved, 2 denied).
  static WithdrawStatus _status(Map<String, dynamic> json) {
    final String status = jsonText(json['status']).toLowerCase();
    if (status.isNotEmpty) {
      return switch (status) {
        'pending' => WithdrawStatus.pending,
        'approved' || 'paid' || 'completed' => WithdrawStatus.approved,
        'denied' ||
        'rejected' ||
        'canceled' ||
        'cancelled' => WithdrawStatus.denied,
        _ => WithdrawStatus.unknown,
      };
    }
    return switch (jsonText(json['approved'])) {
      '0' => WithdrawStatus.pending,
      '1' => WithdrawStatus.approved,
      '2' => WithdrawStatus.denied,
      _ => WithdrawStatus.unknown,
    };
  }
}
