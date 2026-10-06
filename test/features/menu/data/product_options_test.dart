import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/menu/data/datasources/catalog_remote_data_source.dart';
import 'package:ssm_merchant/features/menu/data/models/catalog_models.dart';
import 'package:ssm_merchant/features/menu/data/repos/catalog_repository_impl.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product_options.dart';

import '../menu_fakes.dart';

const ProductOptions sizesAndCheese = ProductOptions(
  variationTitle: 'Size',
  variations: <ProductVariation>[
    ProductVariation(name: 'Small', price: 19.5, stock: 10),
    ProductVariation(name: 'Large', price: 27),
  ],
  addOns: <ProductAddOn>[ProductAddOn(name: 'Cheese', price: 5)],
);

void main() {
  group('request', () {
    late FakeDioConsumer client;
    late CatalogRepositoryImpl repository;

    setUp(() {
      client = FakeDioConsumer()..response = <String, dynamic>{'item_id': 4};
      repository = CatalogRepositoryImpl(
        remote: CatalogRemoteDataSourceImpl(client: client),
      );
    });

    test('PUTs variations with their choice group and add-ons', () async {
      final result = await repository.updateOptions(4, sizesAndCheese);

      expect(result, const Right<Failure, ProductOptions>(sizesAndCheese));
      expect(client.calls.single.verb, 'PUT');
      expect(client.calls.single.path, ApiEndpoints.catalogItemOptions(4));
      expect(client.calls.single.body, <String, dynamic>{
        'variations': <Map<String, dynamic>>[
          <String, dynamic>{'type': 'Small', 'price': 19.5, 'stock': 10},
          <String, dynamic>{'type': 'Large', 'price': 27.0},
        ],
        'choice_options': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'choice_1',
            'title': 'Size',
            'options': <String>['Small', 'Large'],
          },
        ],
        'add_ons': <Map<String, dynamic>>[
          <String, dynamic>{'name': 'Cheese', 'price': 5.0},
        ],
      });
    });

    test('clearing everything still sends every key', () async {
      await repository.updateOptions(4, ProductOptions.none);

      expect(client.calls.single.body, <String, dynamic>{
        'variations': <Map<String, dynamic>>[],
        'choice_options': <Map<String, dynamic>>[],
        'add_ons': <Map<String, dynamic>>[],
      });
    });

    test('a refusal surfaces the server message', () async {
      client.error = const ServerException(
        message: 'The options are required.',
        statusCode: 422,
        code: 'options_required',
      );

      final result = await repository.updateOptions(4, ProductOptions.none);

      expect(
        result,
        const Left<Failure, ProductOptions>(
          ServerFailure(message: 'The options are required.'),
        ),
      );
    });
  });

  group('parsing', () {
    test('reads options stored as lists', () {
      final ProductOptions options = parseProductOptions(<String, dynamic>{
        'variations': <dynamic>[
          <String, dynamic>{'type': 'Small', 'price': '19.50', 'stock': 10},
        ],
        'choice_options': <dynamic>[
          <String, dynamic>{'title': 'Size'},
        ],
        'add_ons': <dynamic>[
          <String, dynamic>{'name': 'Cheese', 'price': 5},
        ],
      });

      expect(
        options,
        const ProductOptions(
          variationTitle: 'Size',
          variations: <ProductVariation>[
            ProductVariation(name: 'Small', price: 19.5, stock: 10),
          ],
          addOns: <ProductAddOn>[ProductAddOn(name: 'Cheese', price: 5)],
        ),
      );
    });

    test('reads JSON-encoded options and skips add-on ids', () {
      final ProductOptions options = parseProductOptions(<String, dynamic>{
        'variations': '[{"type":"Large","price":27}]',
        'add_ons': '[3, 4]',
      });

      expect(options.variations.single.name, 'Large');
      expect(options.addOns, isEmpty);
    });

    test('a product without options has none', () {
      expect(
        ProductModel.fromJson(<String, dynamic>{'id': 1}).options,
        ProductOptions.none,
      );
    });
  });

  group('validation', () {
    test('valid options pass', () {
      expect(sizesAndCheese.validationError, isNull);
    });

    test('variations need a group title', () {
      expect(
        const ProductOptions(
          variations: <ProductVariation>[
            ProductVariation(name: 'Small', price: 1),
          ],
        ).validationError,
        ProductOptionsError.missingTitle,
      );
    });

    test('names must differ, ignoring case', () {
      expect(
        const ProductOptions(
          variationTitle: 'Size',
          variations: <ProductVariation>[
            ProductVariation(name: 'Large', price: 1),
            ProductVariation(name: 'large ', price: 2),
          ],
        ).validationError,
        ProductOptionsError.duplicateName,
      );
    });

    test('a variation needs a price; an add-on may be free', () {
      expect(
        const ProductOptions(
          variationTitle: 'Size',
          variations: <ProductVariation>[
            ProductVariation(name: 'Small', price: 0),
          ],
        ).validationError,
        ProductOptionsError.invalidPrice,
      );
      expect(
        const ProductOptions(
          addOns: <ProductAddOn>[ProductAddOn(name: 'Napkins', price: 0)],
        ).validationError,
        isNull,
      );
    });
  });
}
