import 'package:ssm_merchant/core/api/api_endpoints.dart';
import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/features/menu/data/datasources/catalog_remote_data_source.dart';
import 'package:ssm_merchant/features/menu/data/repos/catalog_repository_impl.dart';
import 'package:ssm_merchant/features/menu/domain/params/product_params.dart';
import 'package:flutter_test/flutter_test.dart';

import '../menu_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late CatalogRepositoryImpl repository;

  Map<String, String> sentFields() => <String, String>{
    for (final MapEntry<String, String> field
        in client.calls.single.formData!.fields)
      field.key: field.value,
  };

  setUp(() {
    client = FakeDioConsumer();
    repository = CatalogRepositoryImpl(
      remote: CatalogRemoteDataSourceImpl(client: client),
    );
  });

  test('getMetadata reads the metadata route', () async {
    client.response = <String, dynamic>{
      'categories': <dynamic>[],
      'units': <dynamic>[],
    };

    final result = await repository.getMetadata();

    expect(result.isRight(), isTrue);
    expect(client.calls.single.path, ApiEndpoints.catalogMetadata);
  });

  test('createProduct posts multipart and unwraps {message, item}', () async {
    client.response = <String, dynamic>{
      'message': 'created',
      'item': <String, dynamic>{'id': 9, 'name': 'Burger', 'status': 1},
    };

    final result = await repository.createProduct(
      const ProductDraft(
        name: ' Burger ',
        description: 'Beef',
        price: 25,
        categoryId: 1,
      ),
    );

    expect(result.getOrElse(() => throw 'failed').id, 9);
    expect(client.calls.single.verb, 'POST');
    expect(client.calls.single.path, ApiEndpoints.catalogItems);
    expect(sentFields(), <String, String>{
      'name': 'Burger',
      'description': 'Beef',
      'price': '25.0',
      'category_id': '1',
    });
  });

  test('updateProduct uses POST on the item with only changed fields', () async {
    client.response = <String, dynamic>{
      'item': <String, dynamic>{'id': 4},
    };

    await repository.updateProduct(4, const ProductUpdate(price: 30));

    expect(client.calls.single.verb, 'POST');
    expect(client.calls.single.path, ApiEndpoints.catalogItem(4));
    expect(sentFields(), <String, String>{'price': '30.0'});
  });

  test('updateStatus PATCHes the status route with a boolean', () async {
    await repository.updateStatus(4, isActive: false);

    expect(client.calls.single.verb, 'PATCH');
    expect(client.calls.single.path, ApiEndpoints.catalogItemStatus(4));
    expect(client.calls.single.body, <String, dynamic>{'status': false});
  });

  test('getProducts sends the search and page size', () async {
    client.response = <String, dynamic>{'data': <dynamic>[]};

    await repository.getProducts(page: 2, search: ' burger ');

    expect(client.calls.single.path, ApiEndpoints.catalogItems);
    expect(client.calls.single.query, <String, dynamic>{
      'page': 2,
      'per_page': CatalogRepositoryImpl.pageSize,
      'search': 'burger',
    });
  });

  test('getProducts omits an empty search', () async {
    client.response = <String, dynamic>{'data': <dynamic>[]};

    await repository.getProducts(page: 1);

    expect(client.calls.single.query?.containsKey('search'), isFalse);
  });

  group('deleteProduct', () {
    test('succeeds on the item route', () async {
      final result = await repository.deleteProduct(4);

      expect(result.isRight(), isTrue);
      expect(client.calls.single.verb, 'DELETE');
      expect(client.calls.single.path, ApiEndpoints.catalogItem(4));
    });

    test('maps a 409 to ConflictFailure', () async {
      client.error = const ConflictException(message: 'used in orders');

      final result = await repository.deleteProduct(4);

      expect(
        result.swap().getOrElse(() => throw 'no failure'),
        isA<ConflictFailure>(),
      );
    });
  });
}
