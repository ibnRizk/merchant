import 'package:dartz/dartz.dart';
import 'package:flutter_base/core/error/failures.dart';
import 'package:flutter_base/features/profile/presentation/cubit/logout/logout_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile_fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late LogoutCubit cubit;

  setUp(() {
    repository = FakeProfileRepository();
    cubit = LogoutCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('emits loading then success', () async {
    final Future<List<LogoutState>> states = cubit.stream.take(2).toList();

    await cubit.logout();

    final List<LogoutState> emitted = await states;
    expect(emitted[0], isA<LogoutLoading>());
    expect(emitted[1], isA<LogoutSuccess>());
  });

  test('emits the failure message when logout fails', () async {
    repository.logoutResult = const Left<Failure, Unit>(
      CacheFailure(message: 'storage unavailable'),
    );

    await cubit.logout();

    expect(cubit.state, isA<LogoutFailure>());
    expect((cubit.state as LogoutFailure).message, 'storage unavailable');
  });

  test('does not log out twice after success', () async {
    await cubit.logout();
    await cubit.logout();

    expect(repository.logoutCalls, 1);
  });
}
