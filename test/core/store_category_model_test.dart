import 'package:flutter_base/core/entities/store_category.dart';
import 'package:flutter_base/core/models/store_category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StoreCategoryModel', () {
    test('parses id and all three names', () {
      final StoreCategoryModel model = StoreCategoryModel.fromJson(
        <String, dynamic>{
          'id': 1,
          'name': 'مطعم',
          'name_ar': 'مطعم',
          'name_en': 'Restaurant',
        },
      );

      expect(model.id, 1);
      expect(model.name, 'مطعم');
      expect(model.nameAr, 'مطعم');
      expect(model.nameEn, 'Restaurant');
    });

    test('tryParse returns null for a store without a category', () {
      expect(StoreCategoryModel.tryParse(null), isNull);
    });
  });

  group('StoreCategory.localizedName', () {
    const StoreCategory category = StoreCategory(
      id: 1,
      name: 'Restaurant',
      nameAr: 'مطعم',
      nameEn: '',
    );

    test('picks the name for the language', () {
      expect(category.localizedName('ar'), 'مطعم');
    });

    test('falls back to name when that translation is missing', () {
      expect(category.localizedName('en'), 'Restaurant');
    });
  });
}
