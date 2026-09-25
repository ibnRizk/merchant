import 'package:ssm_merchant/features/profile/data/models/profile_requests.dart';
import 'package:ssm_merchant/features/profile/domain/params/update_profile_params.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile_fakes.dart';

UpdateProfileParams _diff({
  String firstName = 'Sara',
  String lastName = 'Ali',
  String storeName = 'Mazaq',
  String storePhone = '+201111111111',
  String storeEmail = 'store@example.com',
  String storeAddress = 'Tahrir St',
}) => UpdateProfileParams.changesFrom(
  sampleProfile,
  firstName: firstName,
  lastName: lastName,
  storeName: storeName,
  storePhone: storePhone,
  storeEmail: storeEmail,
  storeAddress: storeAddress,
);

void main() {
  group('UpdateProfileParams.changesFrom', () {
    test('is empty when nothing changed', () {
      expect(_diff().isEmpty, isTrue);
    });

    test('treats surrounding whitespace as unchanged', () {
      expect(_diff(storeName: '  Mazaq  ').isEmpty, isTrue);
    });

    test('keeps only the changed fields, trimmed', () {
      final UpdateProfileParams params = _diff(storeName: ' New Name ');

      expect(params, const UpdateProfileParams(storeName: 'New Name'));
    });
  });

  group('UpdateProfileRequest.toJson', () {
    test('sends only non-null fields under the API keys', () {
      const UpdateProfileParams params = UpdateProfileParams(
        firstName: 'Mona',
        storeAddress: 'Nile St',
      );

      expect(params.toJson(), <String, dynamic>{
        'f_name': 'Mona',
        'store_address': 'Nile St',
      });
    });
  });
}
