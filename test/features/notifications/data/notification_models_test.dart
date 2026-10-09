import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/notifications/data/models/notification_models.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/app_notification.dart';

void main() {
  group('AppNotificationModel.fromJson', () {
    test('reads the top-level fields of the API resource', () {
      final AppNotification n =
          AppNotificationModel.fromJson(const <String, dynamic>{
            'id': '9b1d-uuid',
            'title': 'New order #120',
            'body': 'A customer placed an order.',
            'type': 'ssm.order.created',
            'order_id': 120,
            'is_read': false,
            'created_at': '2026-10-09T08:30:00Z',
          });

      expect(n.id, '9b1d-uuid');
      expect(n.title, 'New order #120');
      expect(n.body, 'A customer placed an order.');
      expect(n.kind, NotificationKind.newOrder);
      expect(n.orderId, 120);
      expect(n.isRead, isFalse);
      expect(n.createdAt, DateTime.utc(2026, 10, 9, 8, 30).toLocal());
    });

    test('falls back to the Laravel `data` payload and `read_at`', () {
      final AppNotification n = AppNotificationModel.fromJson(
        const <String, dynamic>{
          'id': 'abc',
          'read_at': '2026-10-09 09:00:00',
          'data': <String, dynamic>{
            'title': 'Driver assigned',
            'message': 'Ahmed is on the way.',
            'event': 'ssm.driver.assigned',
            'order_id': '55',
          },
        },
      );

      expect(n.title, 'Driver assigned');
      expect(n.body, 'Ahmed is on the way.');
      expect(n.kind, NotificationKind.delivery);
      expect(n.orderId, 55);
      expect(n.isRead, isTrue);
    });

    test('an entry without an id is rejected', () {
      expect(
        () => AppNotificationModel.fromJson(const <String, dynamic>{
          'title': 'x',
        }),
        throwsA(isA<ServerException>()),
      );
    });

    test('no order id stays null rather than 0', () {
      final AppNotification n = AppNotificationModel.fromJson(
        const <String, dynamic>{'id': 'a', 'order_id': null},
      );
      expect(n.orderId, isNull);
    });
  });

  group('kindOf', () {
    test('maps type keywords to kinds', () {
      expect(
        AppNotificationModel.kindOf('ssm.dispatch.assignment_failed'),
        NotificationKind.delivery,
      );
      expect(
        AppNotificationModel.kindOf('App\\Notifications\\NewOrder'),
        NotificationKind.newOrder,
      );
      expect(
        AppNotificationModel.kindOf('ssm.order.status_changed'),
        NotificationKind.orderUpdate,
      );
      expect(
        AppNotificationModel.kindOf('withdraw_approved'),
        NotificationKind.wallet,
      );
      expect(AppNotificationModel.kindOf(''), NotificationKind.general);
    });
  });

  group('NotificationsPageModel.fromJson', () {
    test('hasMore follows meta.current_page < meta.last_page', () {
      final NotificationsPageModel more = NotificationsPageModel.fromJson(
        const <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': 'a'},
          ],
          'links': <String, dynamic>{},
          'meta': <String, dynamic>{'current_page': 1, 'last_page': 3},
        },
      );
      final NotificationsPageModel last = NotificationsPageModel.fromJson(
        const <String, dynamic>{
          'data': <dynamic>[],
          'meta': <String, dynamic>{'current_page': 3, 'last_page': 3},
        },
      );

      expect(more.items, hasLength(1));
      expect(more.hasMore, isTrue);
      expect(last.hasMore, isFalse);
    });

    test('without meta, hasMore follows links.next', () {
      final NotificationsPageModel page = NotificationsPageModel.fromJson(
        const <String, dynamic>{
          'data': <dynamic>[],
          'links': <String, dynamic>{'next': '/vendor/notifications?page=2'},
        },
      );
      expect(page.hasMore, isTrue);
    });
  });
}
