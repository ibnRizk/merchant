import 'package:equatable/equatable.dart';

import 'app_notification.dart';

/// One page of the inbox, newest first.
class NotificationsPage extends Equatable {
  final List<AppNotification> items;
  final bool hasMore;

  const NotificationsPage({required this.items, required this.hasMore});

  @override
  List<Object?> get props => [items, hasMore];
}
