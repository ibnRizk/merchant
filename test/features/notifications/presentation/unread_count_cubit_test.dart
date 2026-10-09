import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/notifications/presentation/cubit/unread_count/unread_count_cubit.dart';

import '../notifications_fakes.dart';

void main() {
  late FakeNotificationsRepository repository;
  late UnreadCountCubit cubit;

  setUp(() {
    repository = FakeNotificationsRepository();
    cubit = UnreadCountCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  test('starts at zero', () => expect(cubit.state, 0));

  test('shows the server count', () async {
    repository.unreadCount = const Right<Failure, int>(5);

    await cubit.refresh();

    expect(cubit.state, 5);
  });

  test('keeps the last known count when a refresh fails', () async {
    repository.unreadCount = const Right<Failure, int>(3);
    await cubit.refresh();
    repository.unreadCount = const Left<Failure, int>(NetworkFailure());

    await cubit.refresh();

    expect(cubit.state, 3);
  });
}
