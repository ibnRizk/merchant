import '../entities/store_category.dart';

/// Parses a category from `GET /auth/vendor/store-categories` and from
/// `stores[0].category` in the profile. Both use the same shape.
class StoreCategoryModel extends StoreCategory {
  const StoreCategoryModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.nameEn,
    super.slug,
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) {
    String text(dynamic value) => value == null ? '' : value.toString().trim();
    return StoreCategoryModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: text(json['name']),
      nameAr: text(json['name_ar']),
      nameEn: text(json['name_en']),
      slug: text(json['slug'] ?? json['key'] ?? json['module_type']),
    );
  }

  /// `null` for anything that isn't a category object, e.g. a store with no
  /// category (`"category": null`).
  static StoreCategoryModel? tryParse(dynamic json) =>
      json is Map<String, dynamic> ? StoreCategoryModel.fromJson(json) : null;
}
