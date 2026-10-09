import '../../utils/json_values.dart';

/// Where tapping a push notification should take the merchant. Parsed from
/// the FCM `data` block, whose values are all strings.
sealed class PushTarget {
  const PushTarget();

  /// An order id wins: the merchant tapped to act on that order. Anything
  /// else opens the inbox, where the full message is.
  factory PushTarget.fromData(Map<String, dynamic> data) {
    final int orderId = jsonInt(
      data['order_id'] ?? data['orderId'],
      fallback: -1,
    );
    return orderId > 0 ? OrderPushTarget(orderId) : const InboxPushTarget();
  }
}

final class OrderPushTarget extends PushTarget {
  final int orderId;

  const OrderPushTarget(this.orderId);

  @override
  bool operator ==(Object other) =>
      other is OrderPushTarget && other.orderId == orderId;

  @override
  int get hashCode => orderId.hashCode;
}

final class InboxPushTarget extends PushTarget {
  const InboxPushTarget();

  @override
  bool operator ==(Object other) => other is InboxPushTarget;

  @override
  int get hashCode => 0;
}
