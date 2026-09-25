import 'dart:convert';

import '../../domain/entities/merchant_order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/entities/order_status.dart';

/// Parses an order from the list, summary and command responses. The docs
/// don't pin every field's type, so numbers are accepted as numbers or
/// strings, and nested objects as maps or JSON-encoded strings.
class MerchantOrderModel extends MerchantOrder {
  const MerchantOrderModel({
    required super.id,
    required super.status,
    required super.amount,
    super.statusVersion,
    super.itemsCount,
    super.createdAt,
    super.customerName,
    super.note,
    super.address,
    super.paymentMethod,
    super.deliveryCharge,
    super.lines,
  });

  factory MerchantOrderModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? customer = _map(json['customer']);
    final Map<String, dynamic>? address = _map(json['delivery_address']);
    final List<OrderLine> lines = _lines(json['details']);
    final String customerName = <String>[
      _text(customer?['f_name']),
      _text(customer?['l_name']),
    ].where((String part) => part.isNotEmpty).join(' ');

    return MerchantOrderModel(
      id: _int(json['id']),
      status: OrderStatus.fromApi(
        _text(json['ssm_status']).isNotEmpty
            ? _text(json['ssm_status'])
            : _text(json['order_status']),
      ),
      statusVersion: int.tryParse('${json['ssm_status_version']}'),
      amount: _double(json['order_amount']),
      itemsCount: _int(
        json['details_count'],
        fallback: lines.fold<int>(
          0,
          (int sum, OrderLine l) => sum + l.quantity,
        ),
      ),
      createdAt: DateTime.tryParse(_text(json['created_at']))?.toLocal(),
      customerName: customerName.isNotEmpty
          ? customerName
          : _text(address?['contact_person_name']),
      note: _text(json['order_note']),
      address: _text(address?['address']),
      paymentMethod: _text(json['payment_method']),
      deliveryCharge: _double(json['delivery_charge']),
      lines: lines,
    );
  }
}

class OrderLineModel extends OrderLine {
  const OrderLineModel({
    required super.id,
    required super.name,
    required super.quantity,
    required super.unitPrice,
    super.addOnsPrice,
    super.extras,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? item =
        _map(json['item_details']) ?? _map(json['item']);
    return OrderLineModel(
      id: _int(json['id']),
      name: _text(item?['name']).isNotEmpty
          ? _text(item?['name'])
          : _text(json['name']),
      quantity: _int(json['quantity'], fallback: 1),
      unitPrice: _double(json['price']),
      addOnsPrice: _double(json['total_add_on_price']),
      extras: <String>[
        ..._names(json['variation']),
        ..._names(json['add_ons']),
      ],
    );
  }
}

class OrderHistoryPageModel extends OrderHistoryPage {
  const OrderHistoryPageModel({
    required super.orders,
    required super.page,
    required super.limit,
    required super.totalSize,
  });

  factory OrderHistoryPageModel.fromJson(Map<String, dynamic> json) {
    final List<MerchantOrder> orders = parseOrders(json['orders']);
    return OrderHistoryPageModel(
      orders: orders,
      page: _int(json['offset'], fallback: 1),
      limit: _int(json['limit'], fallback: orders.length),
      totalSize: _int(json['total_size'], fallback: orders.length),
    );
  }
}

/// `{order: {...}}` from a command response. Only the status fields are
/// read: the rest of the order hasn't changed.
OrderStatusChange parseStatusChange(Map<String, dynamic> json, int orderId) {
  final Map<String, dynamic> order = _map(json['order']) ?? json;
  return OrderStatusChange(
    orderId: _int(order['id'], fallback: orderId),
    status: OrderStatus.fromApi(_text(order['ssm_status'])),
    statusVersion: int.tryParse('${order['ssm_status_version']}'),
  );
}

List<MerchantOrder> parseOrders(dynamic list) => <MerchantOrder>[
  if (list is List)
    for (final dynamic item in list)
      if (item is Map<String, dynamic>) MerchantOrderModel.fromJson(item),
];

/// `order-details` answers with a bare array; tolerate `{details: [...]}`.
List<OrderLine> parseOrderLines(dynamic response) =>
    _lines(response is Map ? response['details'] : response);

List<OrderLine> _lines(dynamic list) => <OrderLine>[
  if (list is List)
    for (final dynamic item in list)
      if (item is Map<String, dynamic>) OrderLineModel.fromJson(item),
];

/// Names from an add-on/variation list, which may be JSON-encoded.
List<String> _names(dynamic value) {
  final dynamic list = value is String ? _decode(value) : value;
  if (list is! List) return const <String>[];
  return <String>[
    for (final dynamic entry in list)
      if (entry is Map && _text(entry['name'] ?? entry['type']).isNotEmpty)
        _text(entry['name'] ?? entry['type']),
  ];
}

Map<String, dynamic>? _map(dynamic value) {
  final dynamic decoded = value is String ? _decode(value) : value;
  return decoded is Map<String, dynamic> ? decoded : null;
}

dynamic _decode(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return null;
  }
}

String _text(dynamic value) => value == null ? '' : value.toString().trim();

int _int(dynamic value, {int fallback = 0}) =>
    int.tryParse('$value') ?? double.tryParse('$value')?.toInt() ?? fallback;

double _double(dynamic value) => double.tryParse('$value') ?? 0;
