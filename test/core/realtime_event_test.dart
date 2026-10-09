import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/realtime/realtime_event.dart';

void main() {
  group('fromWire', () {
    test('matches the wire name with or without the Echo leading dot', () {
      expect(
        RealtimeEvent.fromWire('ssm.order.status_changed', null)?.type,
        RealtimeEventType.orderStatusChanged,
      );
      expect(
        RealtimeEvent.fromWire('.ssm.order.status_changed', null)?.type,
        RealtimeEventType.orderStatusChanged,
      );
    });

    test('maps all five server events', () {
      expect(
        <String>[
          'ssm.order.created',
          'ssm.order.status_changed',
          'ssm.driver.assigned',
          'ssm.dispatch.assignment_failed',
          'ssm.notification.created',
        ].map((String name) => RealtimeEvent.fromWire(name, null)?.type),
        <RealtimeEventType>[
          RealtimeEventType.orderCreated,
          RealtimeEventType.orderStatusChanged,
          RealtimeEventType.driverAssigned,
          RealtimeEventType.dispatchAssignmentFailed,
          RealtimeEventType.notificationCreated,
        ],
      );
    });

    test('ignores protocol and unknown events', () {
      expect(
        RealtimeEvent.fromWire('pusher:subscription_succeeded', null),
        isNull,
      );
      expect(RealtimeEvent.fromWire('ssm.something.else', null), isNull);
    });

    test('reads the order id from order_id, orderId or order.id', () {
      int? idOf(Map<String, dynamic> data) =>
          RealtimeEvent.fromWire('ssm.order.created', data)?.orderId;

      expect(idOf(<String, dynamic>{'order_id': 12}), 12);
      expect(idOf(<String, dynamic>{'orderId': '13'}), 13);
      expect(
        idOf(<String, dynamic>{
          'order': <String, dynamic>{'id': 14},
        }),
        14,
      );
      expect(idOf(<String, dynamic>{}), isNull);
    });
  });

  group('routing helpers', () {
    test('order events affect orders, not the inbox', () {
      const RealtimeEvent event = RealtimeEvent(
        RealtimeEventType.driverAssigned,
      );
      expect(event.affectsOrders, isTrue);
      expect(event.affectsNotifications, isFalse);
    });

    test('notification events affect the inbox, not orders', () {
      const RealtimeEvent event = RealtimeEvent(
        RealtimeEventType.notificationCreated,
      );
      expect(event.affectsOrders, isFalse);
      expect(event.affectsNotifications, isTrue);
    });

    test('a resync affects everything', () {
      expect(RealtimeEvent.resync.affectsOrders, isTrue);
      expect(RealtimeEvent.resync.affectsNotifications, isTrue);
    });

    test('concernsOrder matches its order, or any when the id is unknown', () {
      const RealtimeEvent forFive = RealtimeEvent(
        RealtimeEventType.orderStatusChanged,
        orderId: 5,
      );
      const RealtimeEvent unknown = RealtimeEvent(
        RealtimeEventType.orderStatusChanged,
      );

      expect(forFive.concernsOrder(5), isTrue);
      expect(forFive.concernsOrder(6), isFalse);
      expect(unknown.concernsOrder(6), isTrue);
    });
  });
}
