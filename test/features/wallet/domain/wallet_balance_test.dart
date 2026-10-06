import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/features/wallet/domain/entities/wallet.dart';

import '../wallet_fakes.dart';

void main() {
  final WalletBalance balance = balanceOf(100);

  test('an amount within the balance is valid', () {
    expect(balance.validateWithdrawal(100), isNull);
  });

  test('an unparsable amount is invalid', () {
    expect(balance.validateWithdrawal(null), WithdrawAmountError.invalid);
  });

  test('an amount below 1 is too low', () {
    expect(balance.validateWithdrawal(0.5), WithdrawAmountError.belowMinimum);
  });

  test('an amount above the available balance is refused', () {
    expect(
      balance.validateWithdrawal(100.01),
      WithdrawAmountError.aboveBalance,
    );
  });
}
