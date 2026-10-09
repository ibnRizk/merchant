import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failure_message.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/app_notification.dart';
import '../../../domain/entities/notifications_page.dart';
import '../../../domain/repos/notifications_repository.dart';
import 'notifications_state.dart';

export 'notifications_state.dart';

/// The notification inbox: paged list, mark one / all as read.
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  /// Bumped on every first-page fetch, so a stale response or next page
  /// can't overwrite a newer list.
  int _generation = 0;

  NotificationsCubit({required NotificationsRepository repository})
    : _repository = repository,
      super(const NotificationsLoading());

  Future<void> load() async {
    final int generation = ++_generation;
    emit(const NotificationsLoading());
    final Either<Failure, NotificationsPage> result = await _repository
        .getNotifications();
    if (isClosed || generation != _generation) return;

    emit(
      result.fold(
        (Failure failure) => NotificationsLoadFailure(failure.displayMessage),
        (NotificationsPage page) => NotificationsLoaded(
          items: page.items,
          page: 1,
          hasMore: page.hasMore,
        ),
      ),
    );
  }

  /// Pull-to-refresh: keeps the list on screen and reports a failure.
  Future<void> refresh() => _reloadFirstPage(reportFailure: true);

  /// Realtime refresh: a failure stays quiet (the list is still valid and
  /// the next event retries); a success also recovers a failed first load.
  Future<void> poll() async {
    if (state is NotificationsLoading) return;
    await _reloadFirstPage(reportFailure: false);
  }

  /// Appends the next page. Does nothing after a failure unless [retry].
  Future<void> loadMore({bool retry = false}) async {
    final NotificationsState current = state;
    if (current is! NotificationsLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        (current.loadMoreFailed && !retry)) {
      return;
    }

    final int generation = _generation;
    final int nextPage = current.page + 1;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    final Either<Failure, NotificationsPage> result = await _repository
        .getNotifications(page: nextPage);
    final NotificationsState latest = state;
    if (isClosed ||
        generation != _generation ||
        latest is! NotificationsLoaded) {
      return;
    }

    emit(
      result.fold(
        (_) => latest.copyWith(isLoadingMore: false, loadMoreFailed: true),
        (NotificationsPage page) {
          // New notifications push older ones down a page; skip repeats.
          final Set<String> shown = <String>{
            for (final AppNotification n in latest.items) n.id,
          };
          return latest.copyWith(
            items: <AppNotification>[
              ...latest.items,
              ...page.items.where((AppNotification n) => !shown.contains(n.id)),
            ],
            page: nextPage,
            // An empty page means the end, whatever the meta claims.
            hasMore: page.hasMore && page.items.isNotEmpty,
            isLoadingMore: false,
          );
        },
      ),
    );
  }

  /// Marks [notification] read at once. If the server refuses, it turns
  /// unread again without a message: the merchant is already moving on to
  /// the order, and the next refresh shows the server's truth anyway.
  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    _replaceReadState(<String>{notification.id}, isRead: true);

    final Either<Failure, Unit> result = await _repository.markAsRead(
      notification.id,
    );
    if (isClosed) return;
    result.fold(
      (_) => _replaceReadState(<String>{notification.id}, isRead: false),
      (_) {},
    );
  }

  /// Marks everything read at once; restores the previous state and says
  /// so if the server refuses.
  Future<void> markAllAsRead() async {
    final NotificationsState current = state;
    if (current is! NotificationsLoaded ||
        current.isMarkingAllRead ||
        !current.hasUnread) {
      return;
    }

    final Set<String> unreadIds = <String>{
      for (final AppNotification n in current.items)
        if (!n.isRead) n.id,
    };
    _replaceReadState(unreadIds, isRead: true, isMarkingAllRead: true);

    final Either<Failure, Unit> result = await _repository.markAllAsRead();
    final NotificationsState latest = state;
    if (isClosed || latest is! NotificationsLoaded) return;

    result.fold((Failure failure) {
      _replaceReadState(unreadIds, isRead: false, isMarkingAllRead: false);
      final NotificationsState reverted = state;
      if (reverted is NotificationsLoaded) {
        emit(
          reverted.copyWith(
            notice: NotificationsNotice(failure.displayMessage),
          ),
        );
      }
    }, (_) => emit(latest.copyWith(isMarkingAllRead: false)));
  }

  Future<void> _reloadFirstPage({required bool reportFailure}) async {
    final NotificationsState current = state;
    if (current is! NotificationsLoaded && reportFailure) return load();

    final int generation = ++_generation;
    final Either<Failure, NotificationsPage> result = await _repository
        .getNotifications();
    final NotificationsState latest = state;
    if (isClosed || generation != _generation) return;

    result.fold(
      (Failure failure) {
        if (reportFailure && latest is NotificationsLoaded) {
          emit(
            latest.copyWith(
              notice: NotificationsNotice(failure.displayMessage),
            ),
          );
        }
      },
      (NotificationsPage page) => emit(
        NotificationsLoaded(items: page.items, page: 1, hasMore: page.hasMore),
      ),
    );
  }

  void _replaceReadState(
    Set<String> ids, {
    required bool isRead,
    bool? isMarkingAllRead,
  }) {
    final NotificationsState current = state;
    if (current is! NotificationsLoaded) return;
    emit(
      current.copyWith(
        items: <AppNotification>[
          for (final AppNotification n in current.items)
            ids.contains(n.id) ? n.copyWith(isRead: isRead) : n,
        ],
        isMarkingAllRead: isMarkingAllRead,
      ),
    );
  }
}
