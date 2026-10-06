import 'package:equatable/equatable.dart';

import '../entities/order_status.dart';

/// Why the merchant rejects an order; [code] is sent as `reason`.
enum RejectReason {
  itemUnavailable('item_unavailable'),
  storeBusy('store_busy'),
  storeClosing('store_closing'),
  other('other');

  final String code;

  const RejectReason(this.code);
}

/// Why the store cancels an order it already accepted.
enum CancelReason {
  itemUnavailable('item_unavailable'),
  storeClosing('store_closing'),
  customerRequest('customer_request'),
  other('other');

  final String code;

  const CancelReason(this.code);
}

/// A status command for one order.
class OrderCommand extends Equatable {
  final int orderId;
  final OrderAction action;

  /// The last `ssm_status_version` seen; a newer one on the server makes the
  /// command fail with a conflict instead of acting on stale data.
  final int? expectedVersion;

  /// Required for [OrderAction.reject] and [OrderAction.cancel].
  final String? reason;
  final String? note;

  const OrderCommand({
    required this.orderId,
    required this.action,
    this.expectedVersion,
    this.reason,
    this.note,
  });

  OrderCommand.reject({
    required this.orderId,
    required RejectReason reason,
    this.expectedVersion,
    this.note,
  }) : action = OrderAction.reject,
       reason = reason.code;

  OrderCommand.cancel({
    required this.orderId,
    required CancelReason reason,
    this.expectedVersion,
    this.note,
  }) : action = OrderAction.cancel,
       reason = reason.code;

  @override
  List<Object?> get props => [orderId, action, expectedVersion, reason, note];
}
