import 'package:equatable/equatable.dart';

import 'order_line.dart';
import 'order_status.dart';

/// An order placed at the merchant's store.
class MerchantOrder extends Equatable {
  final int id;
  final OrderStatus status;

  /// `ssm_status_version`: sent back as `expected_version` so the server can
  /// refuse a command based on a stale view (HTTP 409).
  final int? statusVersion;

  final double amount;
  final int itemsCount;
  final DateTime? createdAt;
  final String customerName;
  final String note;
  final String address;
  final String paymentMethod;
  final double deliveryCharge;

  /// Lines, when the list response embeds them; otherwise empty and
  /// fetched separately.
  final List<OrderLine> lines;

  const MerchantOrder({
    required this.id,
    required this.status,
    required this.amount,
    this.statusVersion,
    this.itemsCount = 0,
    this.createdAt,
    this.customerName = '',
    this.note = '',
    this.address = '',
    this.paymentMethod = '',
    this.deliveryCharge = 0,
    this.lines = const <OrderLine>[],
  });

  MerchantOrder copyWith({OrderStatus? status, int? statusVersion}) =>
      MerchantOrder(
        id: id,
        status: status ?? this.status,
        statusVersion: statusVersion ?? this.statusVersion,
        amount: amount,
        itemsCount: itemsCount,
        createdAt: createdAt,
        customerName: customerName,
        note: note,
        address: address,
        paymentMethod: paymentMethod,
        deliveryCharge: deliveryCharge,
        lines: lines,
      );

  /// This order after a successful command. A status the app doesn't know
  /// keeps the current one rather than hiding the order.
  MerchantOrder applyChange(OrderStatusChange change) => copyWith(
    status: change.status == OrderStatus.unknown ? null : change.status,
    statusVersion: change.statusVersion,
  );

  @override
  List<Object?> get props => [
    id,
    status,
    statusVersion,
    amount,
    itemsCount,
    createdAt,
    customerName,
    note,
    address,
    paymentMethod,
    deliveryCharge,
    lines,
  ];
}

/// The outcome of an order command: the order's new status and version.
class OrderStatusChange extends Equatable {
  final int orderId;
  final OrderStatus status;
  final int? statusVersion;

  const OrderStatusChange({
    required this.orderId,
    required this.status,
    this.statusVersion,
  });

  @override
  List<Object?> get props => [orderId, status, statusVersion];
}

/// One page of `GET /vendor/completed-orders`.
class OrderHistoryPage extends Equatable {
  final List<MerchantOrder> orders;
  final int page;
  final int limit;
  final int totalSize;

  const OrderHistoryPage({
    required this.orders,
    required this.page,
    required this.limit,
    required this.totalSize,
  });

  bool get hasMore => page * limit < totalSize;

  @override
  List<Object?> get props => [orders, page, limit, totalSize];
}
