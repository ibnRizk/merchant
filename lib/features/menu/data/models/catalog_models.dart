import 'dart:convert';

import '../../domain/entities/catalog_metadata.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_options.dart';

class CatalogOptionModel extends CatalogOption {
  const CatalogOptionModel({required super.id, required super.name});

  factory CatalogOptionModel.fromJson(Map<String, dynamic> json) =>
      CatalogOptionModel(id: _int(json['id']), name: _text(json['name']));
}

class CatalogMetadataModel extends CatalogMetadata {
  const CatalogMetadataModel({required super.categories, required super.units});

  factory CatalogMetadataModel.fromJson(Map<String, dynamic> json) =>
      CatalogMetadataModel(
        categories: _options(json['categories']),
        units: _options(json['units']),
      );
}

/// Parses a catalog item. The API's docs don't pin every field's type, so
/// numbers and flags are accepted as numbers, strings or booleans.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.isActive,
    super.imageUrl,
    super.category,
    super.options,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final dynamic category = json['category'];
    return ProductModel(
      id: _int(json['id']),
      name: _text(json['name']),
      description: _text(json['description']),
      price: double.tryParse('${json['price']}') ?? 0,
      isActive: _flag(json['status']),
      // `image_full_url` is absolute; `image` may be a bare file name.
      imageUrl: _url(json['image_full_url']) ?? _url(json['image']),
      category: category is Map<String, dynamic>
          ? CatalogOptionModel.fromJson(category)
          : null,
      options: parseProductOptions(json),
    );
  }
}

/// Reads `variations`, `choice_options` and `add_ons` off a catalog item.
/// The API stores them as JSON, so each may arrive as a list or as a
/// JSON-encoded string. Add-ons that are bare ids (another catalog's
/// add-on records) are skipped: they can't be edited here. Returns the
/// plain entity so it compares equal to options built in the app.
ProductOptions parseProductOptions(Map<String, dynamic> json) {
  final List<dynamic> choices = _jsonArray(json['choice_options']);
  final dynamic firstChoice = choices.isEmpty ? null : choices.first;
  return ProductOptions(
    variationTitle: firstChoice is Map ? _text(firstChoice['title']) : '',
    variations: <ProductVariation>[
      for (final dynamic item in _jsonArray(json['variations']))
        if (item is Map && _text(item['type']).isNotEmpty)
          ProductVariation(
            name: _text(item['type']),
            price: double.tryParse('${item['price']}') ?? 0,
            stock: int.tryParse('${item['stock']}'),
          ),
    ],
    addOns: <ProductAddOn>[
      for (final dynamic item in _jsonArray(json['add_ons']))
        if (item is Map && _text(item['name']).isNotEmpty)
          ProductAddOn(
            name: _text(item['name']),
            price: double.tryParse('${item['price']}') ?? 0,
          ),
    ],
  );
}

List<dynamic> _jsonArray(dynamic value) {
  if (value is List) return value;
  if (value is String && value.trim().isNotEmpty) {
    try {
      final dynamic decoded = jsonDecode(value);
      if (decoded is List) return decoded;
    } on FormatException {
      return const <dynamic>[];
    }
  }
  return const <dynamic>[];
}

/// Laravel pagination: either flat (`data`, `current_page`, `last_page`) or
/// resource style with the numbers under `meta`.
class ProductPageModel extends ProductPage {
  const ProductPageModel({
    required super.products,
    required super.currentPage,
    required super.lastPage,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final dynamic meta = json['meta'];
    final Map<String, dynamic> paging = meta is Map<String, dynamic>
        ? meta
        : json;
    final dynamic data = json['data'];
    final int currentPage = _int(paging['current_page'], fallback: 1);
    return ProductPageModel(
      products: <Product>[
        if (data is List)
          for (final dynamic item in data)
            if (item is Map<String, dynamic>) ProductModel.fromJson(item),
      ],
      currentPage: currentPage,
      lastPage: _int(paging['last_page'], fallback: currentPage),
    );
  }
}

List<CatalogOption> _options(dynamic list) => <CatalogOption>[
  if (list is List)
    for (final dynamic item in list)
      if (item is Map<String, dynamic>) CatalogOptionModel.fromJson(item),
];

String _text(dynamic value) => value == null ? '' : value.toString().trim();

int _int(dynamic value, {int fallback = 0}) =>
    int.tryParse('$value') ?? fallback;

bool _flag(dynamic value) =>
    value == true || value == 1 || value == '1' || value == 'true';

String? _url(dynamic value) {
  final String text = _text(value);
  return text.startsWith('http') ? text : null;
}
