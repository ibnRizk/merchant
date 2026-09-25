import 'package:ssm_merchant/features/profile/data/models/merchant_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MerchantProfileModel.fromJson', () {
    test('reads merchant fields and the first store', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{
          'id': 7,
          'f_name': 'Sara',
          'l_name': 'Ali',
          'email': 'sara@example.com',
          'phone': '+201000000000',
          'stores': <dynamic>[
            <String, dynamic>{
              'id': '42',
              'name': 'Mazaq',
              'phone': '+201111111111',
              'email': 'store@example.com',
              'address': 'Tahrir St',
              'logo_full_url': 'https://cdn.example.com/logo.png',
            },
          ],
        },
      );

      expect(model.id, 7);
      expect(model.fullName, 'Sara Ali');
      expect(model.store?.id, 42);
      expect(model.store?.name, 'Mazaq');
      expect(model.store?.logoUrl, 'https://cdn.example.com/logo.png');
    });

    test('reads the store category', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{
          'id': 1,
          'stores': <dynamic>[
            <String, dynamic>{
              'id': 2,
              'category': <String, dynamic>{
                'id': 3,
                'name': 'Restaurant',
                'name_ar': 'مطعم',
                'name_en': 'Restaurant',
              },
            },
          ],
        },
      );

      expect(model.store?.category?.id, 3);
      expect(model.store?.category?.localizedName('ar'), 'مطعم');
    });

    test('has no category when the store has none', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{
          'id': 1,
          'stores': <dynamic>[
            <String, dynamic>{'id': 2, 'category': null},
          ],
        },
      );

      expect(model.store?.category, isNull);
    });

    test('has no store when stores[] is missing or empty', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{'id': 1, 'f_name': 'Sara', 'stores': <dynamic>[]},
      );

      expect(model.store, isNull);
    });

    test('turns null fields into empty strings', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{'id': 1, 'f_name': null, 'email': null},
      );

      expect(model.firstName, isEmpty);
      expect(model.email, isEmpty);
    });

    test('ignores a logo that is a bare file name, not a URL', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{
          'id': 1,
          'stores': <dynamic>[
            <String, dynamic>{'id': 2, 'logo': '2024-logo.png'},
          ],
        },
      );

      expect(model.store?.logoUrl, isNull);
    });

    test('reads the store as open from active = 1', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{
          'id': 1,
          'stores': <dynamic>[
            <String, dynamic>{'id': 2, 'active': 1},
          ],
        },
      );

      expect(model.store?.isOpen, isTrue);
    });

    test('reads the store as closed when active is missing', () {
      final MerchantProfileModel model = MerchantProfileModel.fromJson(
        <String, dynamic>{
          'id': 1,
          'stores': <dynamic>[
            <String, dynamic>{'id': 2},
          ],
        },
      );

      expect(model.store?.isOpen, isFalse);
    });
  });
}
