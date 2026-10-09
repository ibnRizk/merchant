import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/json_values.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notifications_page.dart';

/// One item of `GET /vendor/notifications`. A Laravel database
/// notification: the message may sit at the top level or inside `data`, so
/// both are read.
class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.kind,
    required super.isRead,
    super.orderId,
    super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final String id = jsonText(json['id']);
    if (id.isEmpty) throw ServerException.unexpectedResponse();

    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    String pick(List<String> keys) {
      for (final String key in keys) {
        final String value = jsonText(json[key] ?? data[key]);
        if (value.isNotEmpty) return value;
      }
      return '';
    }

    final int orderId = jsonInt(
      json['order_id'] ?? data['order_id'] ?? data['orderId'],
      fallback: -1,
    );
    return AppNotificationModel(
      id: id,
      title: pick(const <String>['title', 'subject']),
      body: pick(const <String>['body', 'message', 'description']),
      kind: kindOf(pick(const <String>['event', 'type', 'kind'])),
      orderId: orderId > 0 ? orderId : null,
      // `is_read` per the API; `read_at` is the Laravel fallback.
      isRead: json.containsKey('is_read')
          ? isTruthy(json['is_read'])
          : json['read_at'] != null,
      createdAt: DateTime.tryParse(jsonText(json['created_at']))?.toLocal(),
    );
  }

  /// Matches on keywords, since the backend's type strings (event names or
  /// notification class names) are not a fixed list.
  static NotificationKind kindOf(String type) {
    final String t = type.toLowerCase();
    if (t.contains('driver') || t.contains('dispatch')) {
      return NotificationKind.delivery;
    }
    if (t.contains('wallet') ||
        t.contains('withdraw') ||
        t.contains('payout')) {
      return NotificationKind.wallet;
    }
    if (t.contains('order') && (t.contains('created') || t.contains('new'))) {
      return NotificationKind.newOrder;
    }
    if (t.contains('order')) return NotificationKind.orderUpdate;
    return NotificationKind.general;
  }
}

/// `{data: [...], links: {next}, meta: {current_page, last_page}}`.
class NotificationsPageModel extends NotificationsPage {
  const NotificationsPageModel({required super.items, required super.hasMore});

  factory NotificationsPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic meta = json['meta'];
    final dynamic links = json['links'];
    final bool hasMore = meta is Map
        ? jsonInt(meta['current_page']) < jsonInt(meta['last_page'])
        : links is Map && links['next'] != null;
    return NotificationsPageModel(
      items: <AppNotification>[
        for (final Map<String, dynamic> item in jsonMaps(json['data']))
          AppNotificationModel.fromJson(item),
      ],
      hasMore: hasMore,
    );
  }
}
