import '../../../domain/entities/app_notification.dart';

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// The first page failed; there is nothing to show.
final class NotificationsLoadFailure extends NotificationsState {
  final String message;

  const NotificationsLoadFailure(this.message);
}

final class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> items;

  /// The last page fetched.
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  /// The next page failed; scrolling stops retrying until asked to.
  final bool loadMoreFailed;
  final bool isMarkingAllRead;

  /// A message to show once (a failed action or refresh).
  final NotificationsNotice? notice;

  const NotificationsLoaded({
    required this.items,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
    this.isMarkingAllRead = false,
    this.notice,
  });

  bool get hasUnread => items.any((AppNotification n) => !n.isRead);

  /// [notice] is not carried over: each emission states its own.
  NotificationsLoaded copyWith({
    List<AppNotification>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
    bool? isMarkingAllRead,
    NotificationsNotice? notice,
  }) => NotificationsLoaded(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
    notice: notice,
  );
}

final class NotificationsNotice {
  final String message;

  // Not const: each notice must be a distinct instance.
  NotificationsNotice(this.message);
}
