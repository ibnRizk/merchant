import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/home/domain/repos/store_status_repository.dart';
import 'package:ssm_merchant/features/home/presentation/cubit/store_status/store_status_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeStoreStatusRepository implements StoreStatusRepository {
  Future<Either<Failure, bool>> Function(bool isOpen) onSet =
      (bool isOpen) async => Right(isOpen);
  final List<bool> requests = <bool>[];

  @override
  Future<Either<Failure, bool>> setStoreOpen({required bool isOpen}) {
    requests.add(isOpen);
    return onSet(isOpen);
  }
}

void main() {
  late FakeStoreStatusRepository repository;
  late StoreStatusCubit cubit;

  setUp(() {
    repository = FakeStoreStatusRepository();
    cubit = StoreStatusCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('ignores a toggle before the status is known', () async {
    await cubit.setOpen(true);

    expect(repository.requests, isEmpty);
  });

  test('flips right away while the request is in flight', () async {
    cubit.seed(isOpen: false);
    final Completer<Either<Failure, bool>> pending = Completer();
    repository.onSet = (_) => pending.future;

    final Future<void> toggle = cubit.setOpen(true);

    expect(cubit.state.isOpen, isTrue);
    expect(cubit.state.isUpdating, isTrue);
    pending.complete(const Right(true));
    await toggle;
    expect(cubit.state.isUpdating, isFalse);
  });

  test('reverts and reports the message when the request fails', () async {
    cubit.seed(isOpen: true);
    repository.onSet = (_) async =>
        const Left(NetworkFailure(message: 'offline'));

    await cubit.setOpen(false);

    expect(cubit.state.isOpen, isTrue);
    expect(cubit.state.failure?.message, 'offline');
  });

  test("keeps the server's answer over the requested value", () async {
    cubit.seed(isOpen: false);
    repository.onSet = (_) async => const Right(false);

    await cubit.setOpen(true);

    expect(cubit.state.isOpen, isFalse);
  });

  test('a seed during an update does not undo it', () async {
    cubit.seed(isOpen: false);
    final Completer<Either<Failure, bool>> pending = Completer();
    repository.onSet = (_) => pending.future;

    final Future<void> toggle = cubit.setOpen(true);
    cubit.seed(isOpen: false);

    expect(cubit.state.isOpen, isTrue);
    pending.complete(const Right(true));
    await toggle;
  });

  test('ignores a second toggle while one is in flight', () async {
    cubit.seed(isOpen: false);
    final Completer<Either<Failure, bool>> pending = Completer();
    repository.onSet = (_) => pending.future;

    final Future<void> first = cubit.setOpen(true);
    await cubit.setOpen(false);
    pending.complete(const Right(true));
    await first;

    expect(repository.requests, <bool>[true]);
  });
}
