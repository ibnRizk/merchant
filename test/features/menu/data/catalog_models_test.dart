import 'package:flutter_base/features/menu/data/models/catalog_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('reads the fields, category and absolute image URL', () {
      final ProductModel model = ProductModel.fromJson(<String, dynamic>{
        'id': 5,
        'name': 'Burger',
        'description': 'Beef',
        'price': '28.50',
        'status': 1,
        'image_full_url': 'https://cdn.example.com/burger.png',
        'category': <String, dynamic>{'id': 3, 'name': 'Burgers'},
      });

      expect(model.id, 5);
      expect(model.price, 28.5);
      expect(model.isActive, isTrue);
      expect(model.imageUrl, 'https://cdn.example.com/burger.png');
      expect(model.category?.name, 'Burgers');
    });

    test('reads status given as a boolean or a string', () {
      expect(ProductModel.fromJson(<String, dynamic>{'status': true}).isActive,
          isTrue);
      expect(ProductModel.fromJson(<String, dynamic>{'status': '0'}).isActive,
          isFalse);
    });

    test('ignores an image that is a bare file name', () {
      final ProductModel model = ProductModel.fromJson(<String, dynamic>{
        'image': '2025-burger.png',
      });

      expect(model.imageUrl, isNull);
    });
  });

  group('ProductPageModel.fromJson', () {
    test('reads flat Laravel pagination', () {
      final ProductPageModel page = ProductPageModel.fromJson(
        <String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': 1},
          ],
          'current_page': 1,
          'last_page': 3,
        },
      );

      expect(page.products.single.id, 1);
      expect(page.hasMore, isTrue);
    });

    test('reads resource pagination under meta', () {
      final ProductPageModel page = ProductPageModel.fromJson(
        <String, dynamic>{
          'data': <dynamic>[],
          'meta': <String, dynamic>{'current_page': 2, 'last_page': 2},
        },
      );

      expect(page.currentPage, 2);
      expect(page.hasMore, isFalse);
    });
  });

  test('CatalogMetadataModel reads categories and units', () {
    final CatalogMetadataModel metadata = CatalogMetadataModel.fromJson(
      <String, dynamic>{
        'categories': <dynamic>[
          <String, dynamic>{'id': 1, 'name': 'Burgers'},
        ],
        'units': <dynamic>[
          <String, dynamic>{'id': 4, 'name': 'Piece'},
        ],
      },
    );

    expect(metadata.categories.single.name, 'Burgers');
    expect(metadata.units.single.id, 4);
    expect(metadata.hasCategory(1), isTrue);
    expect(metadata.hasCategory(2), isFalse);
  });
}
