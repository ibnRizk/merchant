import '../../domain/entities/order_status.dart';

/// A one-off outcome of an order command for the UI to announce. Instances
/// are never const, so a listener can tell a fresh notice apart with
/// `identical`.
sealed class OrderNotice {
  const OrderNotice();
}

final class OrderUpdatedNotice extends OrderNotice {
  final int orderId;
  final OrderStatus status;

  // Not const: each notice must be a distinct instance.
  OrderUpdatedNotice({required this.orderId, required this.status});
}

/// The order changed elsewhere (another device, or the customer cancelled)
/// since it was loaded: HTTP 409, a 422 transition or a 404. The data is
/// reloaded.
final class OrderConflictNotice extends OrderNotice {
  OrderConflictNotice();
}

/// Dispatch restarted for an order no driver had accepted.
final class OrderDispatchRetriedNotice extends OrderNotice {
  OrderDispatchRetriedNotice();
}

final class OrderActionFailedNotice extends OrderNotice {
  final String message;

  OrderActionFailedNotice(this.message);
}
