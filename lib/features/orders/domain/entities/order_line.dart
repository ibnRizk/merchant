import 'package:equatable/equatable.dart';

/// One line of an order: a product with its quantity and extras.
class OrderLine extends Equatable {
  final int id;
  final String name;
  final int quantity;

  /// Price of one unit, before add-ons.
  final double unitPrice;

  /// Add-ons for the whole line (all units).
  final double addOnsPrice;

  /// Add-on and variation labels, e.g. `Cheese`, `Large`.
  final List<String> extras;

  const OrderLine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.addOnsPrice = 0,
    this.extras = const <String>[],
  });

  double get total => unitPrice * quantity + addOnsPrice;

  @override
  List<Object?> get props => [
    id,
    name,
    quantity,
    unitPrice,
    addOnsPrice,
    extras,
  ];
}
