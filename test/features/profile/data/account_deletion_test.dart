import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ssm_merchant/features/profile/data/repos/profile_repository_impl.dart';
import 'package:ssm_merchant/features/profile/domain/entities/account_deletion.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late ProfileRepositoryImpl repository;

  setUp(() {
    client = FakeDioConsumer();
    repository = ProfileRepositoryImpl(
      remote: ProfileRemoteDataSourceImpl(client: client),
      secureStorage: FakeSecureStorage(accessToken: 'token'),
    );
  });

  Failure failureOf(dynamic result) =>
      result.swap().getOrElse(() => throw 'no failure') as Failure;

  test('DELETEs /vendor/account with the trimmed reason', () async {
    client.response = <String, dynamic>{'status': 'pending'};

    final result = await repository.requestAccountDeletion(
      reason: '  Closing the shop ',
    );

    expect(result.isRight(), isTrue);
    expect(client.calls.single.verb, 'DELETE');
    expect(client.calls.single.path, ApiEndpoints.vendorAccount);
    expect(client.calls.single.body, <String, dynamic>{
      'reason': 'Closing the shop',
    });
  });

  test('sends no body without a reason', () async {
    client.response = <String, dynamic>{'status': 'pending'};

    await repository.requestAccountDeletion(reason: '   ');

    expect(client.calls.single.body, isNull);
  });

  test('409 active_orders_exist is a blocked failure', () async {
    client.error = const ConflictException(
      message: 'Active orders exist.',
      code: 'active_orders_exist',
    );

    final result = await repository.requestAccountDeletion();

    expect(
      failureOf(result),
      const AccountDeletionBlockedFailure(
        reason: DeletionBlockReason.activeOrders,
        message: 'Active orders exist.',
      ),
    );
  });

  test('409 wallet_balance_not_settled is a blocked failure', () async {
    client.error = const ConflictException(code: 'wallet_balance_not_settled');

    final result = await repository.requestAccountDeletion();

    expect(
      (failureOf(result) as AccountDeletionBlockedFailure).reason,
      DeletionBlockReason.walletNotSettled,
    );
  });

  test('an unknown 409 stays a plain conflict', () async {
    client.error = const ConflictException(message: 'Nope', code: 'other');

    final result = await repository.requestAccountDeletion();

    expect(
      failureOf(result),
      const ConflictFailure(message: 'Nope', code: 'other'),
    );
  });

  test('other errors pass through', () async {
    client.error = const InternetConnectionException(message: 'offline');

    final result = await repository.requestAccountDeletion();

    expect(failureOf(result), const NetworkFailure(message: 'offline'));
  });
}
