import '../utils/json_values.dart';

/// What happened on the merchant's private channel. Every event is a refresh
/// signal only: screens re-read the REST endpoint they show, they never
/// trust the event payload as data.
enum RealtimeEventType {
  orderCreated('ssm.order.created'),

  /// Includes cancellations and rejections.
  orderStatusChanged('ssm.order.status_changed'),
  driverAssigned('ssm.driver.assigned'),
  dispatchAssignmentFailed('ssm.dispatch.assignment_failed'),
  notificationCreated('ssm.notification.created'),

  /// Not sent by the server: raised after the socket reconnects, since any
  /// event in between was missed. Everything should refresh.
  resync(null);

  const RealtimeEventType(this.wireName);

  /// The Pusher event name. Laravel Echo writes it with a leading dot
  /// (`.ssm.order.created`) to skip its namespace; the wire has none.
  final String? wireName;
}

class RealtimeEvent {
  final RealtimeEventType type;

  /// The order the event is about, when the payload names one.
  final int? orderId;

  const RealtimeEvent(this.type, {this.orderId});

  static const RealtimeEvent resync = RealtimeEvent(RealtimeEventType.resync);

  /// `null` for events this app doesn't handle (including `pusher:*`).
  static RealtimeEvent? fromWire(String name, Map<String, dynamic>? data) {
    final String bare = name.startsWith('.') ? name.substring(1) : name;
    for (final RealtimeEventType type in RealtimeEventType.values) {
      if (type.wireName == bare) {
        return RealtimeEvent(type, orderId: _orderIdOf(data));
      }
    }
    return null;
  }

  /// Orders, the dashboard counts and history may have changed.
  bool get affectsOrders => type != RealtimeEventType.notificationCreated;

  /// The inbox and its unread count may have changed. Order events usually
  /// come with a notification, but that one has its own event; a resync
  /// covers anything missed.
  bool get affectsNotifications =>
      type == RealtimeEventType.notificationCreated ||
      type == RealtimeEventType.resync;

  /// True when this event may concern order [id]. Events without an order
  /// id count as "maybe", so a screen never misses its update.
  bool concernsOrder(int id) =>
      affectsOrders && (orderId == null || orderId == id);

  /// Accepts `{order_id}`, `{orderId}` or `{order: {id}}`.
  static int? _orderIdOf(Map<String, dynamic>? data) {
    if (data == null) return null;
    final dynamic order = data['order'];
    final dynamic raw =
        data['order_id'] ??
        data['orderId'] ??
        (order is Map ? order['id'] : null);
    final int id = jsonInt(raw, fallback: -1);
    return id > 0 ? id : null;
  }

  @override
  bool operator ==(Object other) =>
      other is RealtimeEvent && other.type == type && other.orderId == orderId;

  @override
  int get hashCode => Object.hash(type, orderId);

  @override
  String toString() => 'RealtimeEvent($type, orderId: $orderId)';
}
