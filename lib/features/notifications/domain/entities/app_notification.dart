import 'package:equatable/equatable.dart';

/// What a notification is about; decides its icon and accent.
enum NotificationKind { newOrder, orderUpdate, delivery, wallet, general }

/// One entry of the merchant's inbox (`GET /vendor/notifications`).
class AppNotification extends Equatable {
  /// A UUID (Laravel database notifications), not a number.
  final String id;
  final String title;
  final String body;
  final NotificationKind kind;

  /// Set when the notification is about an order; tapping opens it.
  final int? orderId;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.isRead,
    this.orderId,
    this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    kind: kind,
    isRead: isRead ?? this.isRead,
    orderId: orderId,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    kind,
    orderId,
    isRead,
    createdAt,
  ];
}
