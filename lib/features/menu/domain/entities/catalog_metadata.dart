import 'package:equatable/equatable.dart';

/// A selectable catalog value: a product category or a unit.
class CatalogOption extends Equatable {
  final int id;
  final String name;

  const CatalogOption({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// `GET /vendor/catalog/metadata`: the values a product can reference.
/// Categories are the active ones for the store's module.
class CatalogMetadata extends Equatable {
  final List<CatalogOption> categories;
  final List<CatalogOption> units;

  const CatalogMetadata({required this.categories, required this.units});

  bool hasCategory(int? id) =>
      id != null && categories.any((CatalogOption c) => c.id == id);

  @override
  List<Object?> get props => [categories, units];
}
