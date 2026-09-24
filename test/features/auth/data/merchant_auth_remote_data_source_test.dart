import 'dart:io';

import 'package:flutter_base/core/api/api_endpoints.dart';
import 'package:flutter_base/core/error/exceptions.dart';
import 'package:flutter_base/core/models/store_category_model.dart';
import 'package:flutter_base/features/auth/data/datasources/merchant_auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth_fakes.dart';

void main() {
  late FakeDioConsumer client;
  late String logoPath;

  MerchantAuthRemoteDataSourceImpl dataSource({
    int? zoneId = 7,
    int? moduleId = 1,
  }) => MerchantAuthRemoteDataSourceImpl(
    client: client,
    zoneId: zoneId,
    moduleId: moduleId,
  );

  Map<String, String> sentFields() => <String, String>{
    for (final MapEntry<String, String> field
        in client.calls.single.formData!.fields)
      field.key: field.value,
  };

  setUp(() async {
    client = FakeDioConsumer();
    logoPath = await createTempLogo();
  });

  tearDown(() => File(logoPath).parent.delete(recursive: true));

  group('getStoreCategories', () {
    test('parses the categories list', () async {
      client.response = <String, dynamic>{
        'categories': <dynamic>[
          <String, dynamic>{
            'id': 1,
            'name': 'مطعم',
            'name_ar': 'مطعم',
            'name_en': 'Restaurant',
          },
        ],
      };

      final List<StoreCategoryModel> categories = await dataSource()
          .getStoreCategories();

      expect(categories.single.id, 1);
      expect(categories.single.nameEn, 'Restaurant');
      expect(client.calls.single.path, ApiEndpoints.storeCategories);
    });

    test('accepts an empty list', () async {
      client.response = <String, dynamic>{'categories': <dynamic>[]};

      expect(await dataSource().getStoreCategories(), isEmpty);
    });

    test('throws when the list is missing', () async {
      client.response = <String, dynamic>{};

      await expectLater(
        dataSource().getStoreCategories(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('register', () {
    setUp(() => client.response = <String, dynamic>{'store_id': 99});

    test('sends zone and module from config and tax 0', () async {
      await dataSource().register(registerParams(logoPath: logoPath));

      final Map<String, String> fields = sentFields();
      expect(fields['zone_id'], '7');
      expect(fields['module_id'], '1');
      expect(fields['tax'], '0');
    });

    test('sends the chosen store_category_id', () async {
      await dataSource().register(registerParams(logoPath: logoPath));

      expect(sentFields()['store_category_id'], '3');
    });

    test('omits store_category_id when none was chosen', () async {
      await dataSource().register(
        registerParams(logoPath: logoPath, storeCategoryId: null),
      );

      expect(sentFields().containsKey('store_category_id'), isFalse);
    });

    test('returns the new store id', () async {
      expect(
        await dataSource().register(registerParams(logoPath: logoPath)),
        99,
      );
    });

    test('fails without calling the API when zone config is missing', () async {
      await expectLater(
        dataSource(zoneId: null).register(registerParams(logoPath: logoPath)),
        throwsA(isA<ServerException>()),
      );
      expect(client.calls, isEmpty);
    });
  });
}
