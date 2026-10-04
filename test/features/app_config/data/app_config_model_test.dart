import 'package:ssm_merchant/core/error/exceptions.dart';
import 'package:ssm_merchant/features/app_config/data/models/app_config_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads support, legal and a currency code', () {
    final AppConfigModel config = AppConfigModel.fromJson(<String, dynamic>{
      'support': <String, dynamic>{
        'phone': '+201000000000',
        'email': 'help@ssm.test',
        'whatsapp': '+20 100 000 0000',
      },
      'legal': <String, dynamic>{
        'privacy_policy': 'https://ssm.test/privacy',
        'terms': 'https://ssm.test/terms',
      },
      'application': <String, dynamic>{
        'currency': 'EGP',
        'timezone': 'Africa/Cairo',
        'maintenance_mode': false,
        'minimum_versions': <String, dynamic>{'android': '1.0.0'},
      },
    });

    expect(config.currency, 'EGP');
    expect(config.supportPhone, '+201000000000');
    expect(config.supportEmail, 'help@ssm.test');
    expect(config.supportWhatsapp, '+20 100 000 0000');
    expect(config.privacyPolicyUrl, 'https://ssm.test/privacy');
    expect(config.termsUrl, 'https://ssm.test/terms');
    expect(config.hasSupport, isTrue);
    expect(config.hasLegal, isTrue);
  });

  test('prefers the currency symbol over its code', () {
    final AppConfigModel config = AppConfigModel.fromJson(<String, dynamic>{
      'application': <String, dynamic>{
        'currency': <String, dynamic>{'code': 'EGP', 'symbol': 'ج.م'},
      },
    });

    expect(config.currency, 'ج.م');
  });

  test('reads a flat currency_symbol', () {
    final AppConfigModel config = AppConfigModel.fromJson(<String, dynamic>{
      'application': <String, dynamic>{
        'currency': 'EGP',
        'currency_symbol': 'E£',
      },
    });

    expect(config.currency, 'E£');
  });

  test('accepts the alternative key spellings', () {
    final AppConfigModel config = AppConfigModel.fromJson(<String, dynamic>{
      'support': <String, dynamic>{'support_email': 'help@ssm.test'},
      'legal': <String, dynamic>{
        'privacy_policy_url': 'https://ssm.test/privacy',
        'terms_and_conditions': 'https://ssm.test/terms',
      },
    });

    expect(config.supportEmail, 'help@ssm.test');
    expect(config.privacyPolicyUrl, 'https://ssm.test/privacy');
    expect(config.termsUrl, 'https://ssm.test/terms');
  });

  test('drops legal links that are not absolute http(s) URLs', () {
    final AppConfigModel config = AppConfigModel.fromJson(<String, dynamic>{
      'legal': <String, dynamic>{
        'privacy_policy': '/privacy',
        'terms': 'javascript:alert(1)',
      },
    });

    expect(config.hasLegal, isFalse);
  });

  test('missing sections leave empty values', () {
    final AppConfigModel config = AppConfigModel.fromJson(<String, dynamic>{
      'application': <String, dynamic>{},
    });

    expect(config.currency, isEmpty);
    expect(config.hasSupport, isFalse);
    expect(config.hasLegal, isFalse);
  });

  test('throws when the body has none of the documented sections', () {
    expect(
      () => AppConfigModel.fromJson(<String, dynamic>{'message': 'ok'}),
      throwsA(isA<ServerException>()),
    );
  });
}
