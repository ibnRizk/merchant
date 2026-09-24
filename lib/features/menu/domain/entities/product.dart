import 'package:equatable/equatable.dart';

import 'catalog_metadata.dart';

/// A product in the merchant's catalog.
class Product extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  /// Whether customers can order it (`status` on the API).
  final bool isActive;
  final CatalogOption? category;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isActive,
    this.imageUrl,
    this.category,
  });

  Product copyWith({bool? isActive}) => Product(
    id: id,
    name: name,
    description: description,
    price: price,
    isActive: isActive ?? this.isActive,
    imageUrl: imageUrl,
    category: category,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    isActive,
    category,
  ];
}

/// One page of `GET /vendor/catalog/items`.
class ProductPage extends Equatable {
  final List<Product> products;
  final int currentPage;
  final int lastPage;

  const ProductPage({
    required this.products,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [products, currentPage, lastPage];
}
