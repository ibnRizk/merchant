import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/app_notification.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/notifications_page.dart';
import 'package:ssm_merchant/features/notifications/presentation/cubit/notifications/notifications_cubit.dart';

import '../notifications_fakes.dart';

Either<Failure, NotificationsPage> page(
  List<AppNotification> items, {
  bool hasMore = false,
}) => Right<Failure, NotificationsPage>(
  NotificationsPage(items: items, hasMore: hasMore),
);

const Left<Failure, Unit> serverDown = Left<Failure, Unit>(
  ServerFailure(message: 'server down'),
);

void main() {
  late FakeNotificationsRepository repository;
  late NotificationsCubit cubit;

  NotificationsLoaded loaded() => cubit.state as NotificationsLoaded;
  List<bool> readFlags() =>
      loaded().items.map((AppNotification n) => n.isRead).toList();

  setUp(() {
    repository = FakeNotificationsRepository();
    cubit = NotificationsCubit(repository: repository);
  });

  tearDown(() => cubit.close());

  group('load', () {
    test('shows the first page', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a'),
      ], hasMore: true);

      await cubit.load();

      expect(loaded().items.single.id, 'a');
      expect(loaded().page, 1);
      expect(loaded().hasMore, isTrue);
    });

    test('a failed first page is a load failure', () async {
      repository.pages[1] = const Left<Failure, NotificationsPage>(
        ServerFailure(message: 'nope'),
      );

      await cubit.load();

      expect((cubit.state as NotificationsLoadFailure).message, 'nope');
    });
  });

  group('loadMore', () {
    test('appends the next page and skips repeats', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a'),
        notification('b'),
      ], hasMore: true);
      repository.pages[2] = page(<AppNotification>[
        notification('b'),
        notification('c'),
      ]);
      await cubit.load();

      await cubit.loadMore();

      expect(loaded().items.map((AppNotification n) => n.id), <String>[
        'a',
        'b',
        'c',
      ]);
      expect(loaded().page, 2);
      expect(loaded().hasMore, isFalse);
    });

    test('stops after a failure until asked to retry', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a'),
      ], hasMore: true);
      repository.pages[2] = const Left<Failure, NotificationsPage>(
        ServerFailure(),
      );
      await cubit.load();

      await cubit.loadMore();
      await cubit.loadMore();
      expect(loaded().loadMoreFailed, isTrue);
      expect(repository.requestedPages, <int>[1, 2]);

      repository.pages[2] = page(<AppNotification>[notification('b')]);
      await cubit.loadMore(retry: true);
      expect(loaded().items, hasLength(2));
    });
  });

  group('markAsRead', () {
    test('marks it read and tells the server', () async {
      repository.pages[1] = page(<AppNotification>[notification('a')]);
      await cubit.load();

      await cubit.markAsRead(loaded().items.single);

      expect(readFlags(), <bool>[true]);
      expect(repository.markedIds, <String>['a']);
    });

    test('turns it unread again when the server refuses', () async {
      repository.pages[1] = page(<AppNotification>[notification('a')]);
      repository.markResult = serverDown;
      await cubit.load();

      await cubit.markAsRead(loaded().items.single);

      expect(readFlags(), <bool>[false]);
    });

    test('an already read notification makes no call', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a', isRead: true),
      ]);
      await cubit.load();

      await cubit.markAsRead(loaded().items.single);

      expect(repository.markedIds, isEmpty);
    });
  });

  group('markAllAsRead', () {
    test('marks every notification read', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a'),
        notification('b', isRead: true),
      ]);
      await cubit.load();

      await cubit.markAllAsRead();

      expect(readFlags(), <bool>[true, true]);
      expect(loaded().hasUnread, isFalse);
      expect(loaded().isMarkingAllRead, isFalse);
      expect(repository.markAllCalls, 1);
    });

    test('restores the unread ones and reports a refusal', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a'),
        notification('b', isRead: true),
      ]);
      repository.markAllResult = serverDown;
      await cubit.load();

      await cubit.markAllAsRead();

      expect(readFlags(), <bool>[false, true]);
      expect(loaded().notice?.message, 'server down');
      expect(loaded().isMarkingAllRead, isFalse);
    });

    test('does nothing when everything is read', () async {
      repository.pages[1] = page(<AppNotification>[
        notification('a', isRead: true),
      ]);
      await cubit.load();

      await cubit.markAllAsRead();

      expect(repository.markAllCalls, 0);
    });
  });

  group('poll', () {
    test('replaces the list with the newest first page', () async {
      repository.pages[1] = page(<AppNotification>[notification('a')]);
      await cubit.load();
      repository.pages[1] = page(<AppNotification>[
        notification('new'),
        notification('a'),
      ]);

      await cubit.poll();

      expect(loaded().items.first.id, 'new');
    });

    test('keeps the list and stays quiet when it fails', () async {
      repository.pages[1] = page(<AppNotification>[notification('a')]);
      await cubit.load();
      repository.pages[1] = const Left<Failure, NotificationsPage>(
        ServerFailure(message: 'offline'),
      );

      await cubit.poll();

      expect(loaded().items.single.id, 'a');
      expect(loaded().notice, isNull);
    });

    test('recovers a failed first load', () async {
      repository.pages[1] = const Left<Failure, NotificationsPage>(
        ServerFailure(),
      );
      await cubit.load();
      repository.pages[1] = page(<AppNotification>[notification('a')]);

      await cubit.poll();

      expect(loaded().items.single.id, 'a');
    });
  });

  test('refresh reports a failure and keeps the list', () async {
    repository.pages[1] = page(<AppNotification>[notification('a')]);
    await cubit.load();
    repository.pages[1] = const Left<Failure, NotificationsPage>(
      ServerFailure(message: 'offline'),
    );

    await cubit.refresh();

    expect(loaded().items.single.id, 'a');
    expect(loaded().notice?.message, 'offline');
  });
}
