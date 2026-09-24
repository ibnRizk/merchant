import 'package:flutter_base/features/menu/domain/entities/product.dart';
import 'package:flutter_base/features/menu/domain/params/product_params.dart';
import 'package:flutter_test/flutter_test.dart';

import '../menu_fakes.dart';

void main() {
  final Product current = product(1);

  ProductDraft draft({
    String? name,
    double? price,
    int? categoryId,
    String? imagePath,
  }) => ProductDraft(
    name: name ?? current.name,
    description: current.description,
    price: price ?? current.price,
    categoryId: categoryId ?? current.category!.id,
    imagePath: imagePath,
  );

  group('ProductUpdate.changesFrom', () {
    test('is empty when nothing changed', () {
      expect(ProductUpdate.changesFrom(current, draft()).isEmpty, isTrue);
    });

    test('treats surrounding whitespace as unchanged', () {
      final ProductUpdate update = ProductUpdate.changesFrom(
        current,
        draft(name: '  ${current.name} '),
      );

      expect(update.isEmpty, isTrue);
    });

    test('keeps only the changed fields', () {
      final ProductUpdate update = ProductUpdate.changesFrom(
        current,
        draft(price: 30, categoryId: drinks.id),
      );

      expect(update, ProductUpdate(price: 30, categoryId: drinks.id));
    });

    test('a newly picked image counts as a change', () {
      final ProductUpdate update = ProductUpdate.changesFrom(
        current,
        draft(imagePath: '/tmp/new.png'),
      );

      expect(update, const ProductUpdate(imagePath: '/tmp/new.png'));
    });
  });
}
