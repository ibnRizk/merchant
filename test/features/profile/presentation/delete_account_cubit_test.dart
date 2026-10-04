import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/profile/domain/entities/account_deletion.dart';
import 'package:ssm_merchant/features/profile/presentation/cubit/delete_account/delete_account_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile_fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late DeleteAccountCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = DeleteAccountCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('emits loading then requested, passing the reason on', () async {
    final Future<List<DeleteAccountState>> states = cubit.stream
        .take(2)
        .toList();

    await cubit.requestDeletion(reason: 'Closing');

    final List<DeleteAccountState> emitted = await states;
    expect(emitted[0], isA<DeleteAccountLoading>());
    expect(emitted[1], isA<DeleteAccountRequested>());
    expect(repository.deletionReasons, <String?>['Closing']);
  });

  test('a blocked request reports why', () async {
    repository.deletionResult = const Left(
      AccountDeletionBlockedFailure(reason: DeletionBlockReason.activeOrders),
    );

    await cubit.requestDeletion();

    expect(
      (cubit.state as DeleteAccountBlocked).reason,
      DeletionBlockReason.activeOrders,
    );
  });

  test('another failure shows its message', () async {
    repository.deletionResult = const Left(ServerFailure(message: 'Down'));

    await cubit.requestDeletion();

    expect((cubit.state as DeleteAccountFailure).message, 'Down');
  });

  test('does not send twice after success', () async {
    await cubit.requestDeletion();
    await cubit.requestDeletion();

    expect(repository.deletionReasons, hasLength(1));
  });

  test('can retry after a blocked request', () async {
    repository.deletionResult = const Left(
      AccountDeletionBlockedFailure(
        reason: DeletionBlockReason.walletNotSettled,
      ),
    );
    await cubit.requestDeletion();
    repository.deletionResult = const Right(unit);

    await cubit.requestDeletion();

    expect(cubit.state, isA<DeleteAccountRequested>());
    expect(repository.deletionReasons, hasLength(2));
  });
}
