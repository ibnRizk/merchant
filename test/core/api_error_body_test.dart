import 'package:ssm_merchant/core/api/api_error_body.dart';
import 'package:ssm_merchant/core/entities/merchant_approval_status.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> errorBody(Map<String, dynamic> error) => <String, dynamic>{
  'errors': <dynamic>[error],
};

void main() {
  group('apiErrorCode', () {
    test('reads the first errors[].code', () {
      expect(
        apiErrorCode(errorBody(<String, dynamic>{'code': 'active_orders_exist'})),
        'active_orders_exist',
      );
    });

    test('is null for Laravel field errors, strings and null', () {
      expect(
        apiErrorCode(<String, dynamic>{
          'errors': <String, dynamic>{
            'email': <String>['taken'],
          },
        }),
        isNull,
      );
      expect(apiErrorCode('<html>'), isNull);
      expect(apiErrorCode(null), isNull);
    });
  });

  group('accountRestrictionOf', () {
    test('merchant-not-approved with pending is pending', () {
      expect(
        accountRestrictionOf(
          errorBody(<String, dynamic>{
            'code': 'merchant-not-approved',
            'approval_status': 'pending',
          }),
        ),
        MerchantApprovalStatus.pending,
      );
    });

    test('merchant-not-approved with rejected is rejected', () {
      expect(
        accountRestrictionOf(
          errorBody(<String, dynamic>{
            'code': 'merchant-not-approved',
            'approval_status': 'rejected',
          }),
        ),
        MerchantApprovalStatus.rejected,
      );
    });

    test('merchant-not-approved without a status counts as pending', () {
      expect(
        accountRestrictionOf(
          errorBody(<String, dynamic>{'code': 'merchant-not-approved'}),
        ),
        MerchantApprovalStatus.pending,
      );
    });

    test('merchant-suspended, in either spelling, is suspended', () {
      expect(
        accountRestrictionOf(
          errorBody(<String, dynamic>{'code': 'merchant-suspended'}),
        ),
        MerchantApprovalStatus.suspended,
      );
      expect(
        accountRestrictionOf(
          errorBody(<String, dynamic>{'code': 'merchant_suspended'}),
        ),
        MerchantApprovalStatus.suspended,
      );
    });

    test('any other 403 is not a restriction', () {
      expect(
        accountRestrictionOf(
          errorBody(<String, dynamic>{'code': 'store_category_id'}),
        ),
        isNull,
      );
      expect(
        accountRestrictionOf(<String, dynamic>{'message': 'Forbidden'}),
        isNull,
      );
    });
  });
}
