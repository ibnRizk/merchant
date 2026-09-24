import 'package:equatable/equatable.dart';

import '../entities/product.dart';

/// The product form's values. Also the body of a create.
class ProductDraft extends Equatable {
  final String name;
  final String description;
  final double price;
  final int categoryId;

  /// Local path of a newly picked image; `null` keeps the current one.
  final String? imagePath;

  const ProductDraft({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imagePath,
  });

  @override
  List<Object?> get props => [name, description, price, categoryId, imagePath];
}

/// Body of `POST /vendor/catalog/items/{id}`. The API updates only the fields
/// that are sent, so a `null` field is left as it is.
class ProductUpdate extends Equatable {
  final String? name;
  final String? description;
  final double? price;
  final int? categoryId;
  final String? imagePath;

  const ProductUpdate({
    this.name,
    this.description,
    this.price,
    this.categoryId,
    this.imagePath,
  });

  /// Keeps only what differs from [current]. Text is compared trimmed.
  factory ProductUpdate.changesFrom(Product current, ProductDraft draft) {
    String? changedText(String edited, String original) {
      final String value = edited.trim();
      return value == original.trim() ? null : value;
    }

    return ProductUpdate(
      name: changedText(draft.name, current.name),
      description: changedText(draft.description, current.description),
      price: draft.price == current.price ? null : draft.price,
      categoryId: draft.categoryId == current.category?.id
          ? null
          : draft.categoryId,
      imagePath: draft.imagePath,
    );
  }

  bool get isEmpty => props.every((Object? value) => value == null);

  @override
  List<Object?> get props => [name, description, price, categoryId, imagePath];
}
