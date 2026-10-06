import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/error/exceptions.dart';
import '../models/wallet_models.dart';

/// Talks to `/vendor/wallet` and `/vendor/withdraw-requests`. Throws
/// [AppException]s; the repository turns them into failures.
abstract class WalletRemoteDataSource {
  Future<WalletOverviewModel> getWallet();

  Future<void> requestWithdrawal(double amount);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final DioConsumer _client;

  const WalletRemoteDataSourceImpl({required DioConsumer client})
    : _client = client;

  @override
  Future<WalletOverviewModel> getWallet() async {
    final dynamic response = await _client.get(ApiEndpoints.wallet);
    if (response is! Map<String, dynamic>) {
      throw ServerException.unexpectedResponse();
    }
    return WalletOverviewModel.fromJson(response);
  }

  /// 201 `{id, status: pending}`; the wallet is reloaded afterwards, so the
  /// body isn't read.
  @override
  Future<void> requestWithdrawal(double amount) => _client.post(
    ApiEndpoints.withdrawRequests,
    body: <String, dynamic>{'amount': amount},
  );
}
