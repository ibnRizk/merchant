import 'package:equatable/equatable.dart';

/// A choice of the product sold at its own price, e.g. a size.
class ProductVariation extends Equatable {
  final String name;

  /// The full price of this variation (not a surcharge).
  final double price;

  /// `null` when stock isn't tracked for it.
  final int? stock;

  const ProductVariation({required this.name, required this.price, this.stock});

  @override
  List<Object?> get props => [name, price, stock];
}

/// An optional extra the customer can add, e.g. extra cheese.
class ProductAddOn extends Equatable {
  final String name;
  final double price;

  const ProductAddOn({required this.name, required this.price});

  @override
  List<Object?> get props => [name, price];
}

/// A product's variations and add-ons
/// (`PUT /vendor/catalog/items/{id}/options`).
class ProductOptions extends Equatable {
  /// What the variations choose, shown to customers (e.g. "Size").
  final String variationTitle;
  final List<ProductVariation> variations;
  final List<ProductAddOn> addOns;

  const ProductOptions({
    this.variationTitle = '',
    this.variations = const <ProductVariation>[],
    this.addOns = const <ProductAddOn>[],
  });

  static const ProductOptions none = ProductOptions();

  bool get isEmpty => variations.isEmpty && addOns.isEmpty;

  /// Why these options can't be saved, or `null` when they can.
  ProductOptionsError? get validationError {
    if (variations.isNotEmpty && variationTitle.trim().isEmpty) {
      return ProductOptionsError.missingTitle;
    }
    final Iterable<String> names = <String>[
      for (final ProductVariation v in variations) v.name,
      for (final ProductAddOn a in addOns) a.name,
    ];
    if (names.any((String name) => name.trim().isEmpty)) {
      return ProductOptionsError.emptyName;
    }
    if (_hasDuplicates(variations.map((ProductVariation v) => v.name)) ||
        _hasDuplicates(addOns.map((ProductAddOn a) => a.name))) {
      return ProductOptionsError.duplicateName;
    }
    if (variations.any((ProductVariation v) => v.price <= 0) ||
        addOns.any((ProductAddOn a) => a.price < 0)) {
      return ProductOptionsError.invalidPrice;
    }
    return null;
  }

  static bool _hasDuplicates(Iterable<String> names) {
    final Set<String> seen = <String>{};
    return names.any((String name) => !seen.add(name.trim().toLowerCase()));
  }

  @override
  List<Object?> get props => [variationTitle, variations, addOns];
}

enum ProductOptionsError {
  missingTitle,
  emptyName,
  duplicateName,
  invalidPrice,
}
