import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/utils/values/strings.dart';
import 'package:ssm_merchant/features/wallet/data/datasources/wallet_remote_data_source.dart';
import 'package:ssm_merchant/features/wallet/domain/entities/wallet.dart';

import '../wallet_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late WalletRemoteDataSourceImpl dataSource;

  setUp(() {
    client = FakeDioConsumer();
    dataSource = WalletRemoteDataSourceImpl(client: client);
  });

  test('reads the balances and paginated withdraw requests', () async {
    client.response = <String, dynamic>{
      'wallet': <String, dynamic>{
        'total_earning': '500.00',
        'total_withdrawn': 100,
        'pending_withdraw': '50',
        'collected_cash': 20,
        'available_balance': '330.00',
      },
      'withdraw_requests': <String, dynamic>{
        'current_page': 1,
        'data': <dynamic>[
          <String, dynamic>{'id': 7, 'amount': '50.00', 'status': 'pending'},
          <String, dynamic>{'id': 6, 'amount': 100, 'approved': 1},
        ],
      },
    };

    final WalletOverview wallet = await dataSource.getWallet();

    expect(client.calls.single.path, ApiEndpoints.wallet);
    expect(wallet.balance.availableBalance, 330);
    expect(wallet.balance.totalEarning, 500);
    expect(
      wallet.withdrawals.map((WithdrawRequest w) => w.status),
      <WithdrawStatus>[WithdrawStatus.pending, WithdrawStatus.approved],
    );
    expect(wallet.withdrawals.first.amount, 50);
  });

  test('a missing balance is an unexpected response', () {
    client.response = <String, dynamic>{
      'wallet': <String, dynamic>{'total_earning': 1},
    };

    expect(
      dataSource.getWallet,
      throwsA(
        isA<ServerException>().having(
          (ServerException e) => e.message,
          'message',
          Strings.unexpectedResponse,
        ),
      ),
    );
  });

  test('a withdrawal posts the amount', () async {
    client.response = <String, dynamic>{'id': 9, 'status': 'pending'};

    await dataSource.requestWithdrawal(75.5);

    expect(client.calls.single.verb, 'POST');
    expect(client.calls.single.path, ApiEndpoints.withdrawRequests);
    expect(client.calls.single.body, <String, dynamic>{'amount': 75.5});
  });
}
