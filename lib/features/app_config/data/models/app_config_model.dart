import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_config.dart';

/// Parses `GET /vendor/config`:
/// `{"support": {...}, "legal": {...}, "application": {"currency", "timezone",
/// "maintenance_mode", "minimum_versions"}}`.
///
/// The docs fix the top-level keys only, so the nested keys accept the
/// common spellings, and `currency` may be a code string or
/// `{code, symbol}`.
class AppConfigModel extends AppConfig {
  const AppConfigModel({
    super.currency,
    super.supportPhone,
    super.supportEmail,
    super.supportWhatsapp,
    super.privacyPolicyUrl,
    super.termsUrl,
  });

  /// Throws [ServerException] when none of the documented sections is a
  /// map: that is not a config response.
  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? support = _map(json['support']);
    final Map<String, dynamic>? legal = _map(json['legal']);
    final Map<String, dynamic>? application = _map(json['application']);
    if (support == null && legal == null && application == null) {
      throw const UnexpectedResponseException();
    }

    return AppConfigModel(
      currency: _currencyOf(application),
      supportPhone: _first(support, const <String>['phone', 'support_phone']),
      supportEmail: _first(support, const <String>['email', 'support_email']),
      supportWhatsapp: _first(support, const <String>[
        'whatsapp',
        'whatsapp_number',
        'support_whatsapp',
      ]),
      privacyPolicyUrl: _url(legal, const <String>[
        'privacy_policy',
        'privacy_policy_url',
        'privacy',
      ]),
      termsUrl: _url(legal, const <String>[
        'terms',
        'terms_url',
        'terms_and_conditions',
        'terms_conditions',
      ]),
    );
  }

  /// A symbol beats a code: `ج.م` reads better than `EGP` in Arabic.
  static String _currencyOf(Map<String, dynamic>? application) {
    if (application == null) return '';
    final String flatSymbol = _first(application, const <String>[
      'currency_symbol',
    ]);
    if (flatSymbol.isNotEmpty) return flatSymbol;
    final dynamic currency = application['currency'];
    if (currency is Map) {
      return _first(Map<String, dynamic>.from(currency), const <String>[
        'symbol',
        'code',
      ]);
    }
    return currency == null ? '' : currency.toString().trim();
  }

  static String _first(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return '';
    for (final String key in keys) {
      final String value = (source[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  /// Only absolute http(s) links: anything else can't be opened.
  static String _url(Map<String, dynamic>? source, List<String> keys) {
    final String value = _first(source, keys);
    final Uri? uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'https' || uri.scheme == 'http')
        ? value
        : '';
  }

  static Map<String, dynamic>? _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
}
