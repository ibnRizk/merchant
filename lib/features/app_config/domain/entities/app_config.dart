import 'package:equatable/equatable.dart';

/// App-wide settings from `GET /vendor/config`. Empty strings mean the server
/// did not send that value; the UI hides what it doesn't have.
class AppConfig extends Equatable {
  /// What to print next to amounts, e.g. `EGP` or `ج.م`.
  final String currency;

  final String supportPhone;
  final String supportEmail;
  final String supportWhatsapp;

  final String privacyPolicyUrl;
  final String termsUrl;

  const AppConfig({
    this.currency = '',
    this.supportPhone = '',
    this.supportEmail = '',
    this.supportWhatsapp = '',
    this.privacyPolicyUrl = '',
    this.termsUrl = '',
  });

  /// Before the first successful fetch.
  static const AppConfig empty = AppConfig();

  bool get hasSupport =>
      supportPhone.isNotEmpty ||
      supportEmail.isNotEmpty ||
      supportWhatsapp.isNotEmpty;

  bool get hasLegal => privacyPolicyUrl.isNotEmpty || termsUrl.isNotEmpty;

  @override
  List<Object?> get props => [
    currency,
    supportPhone,
    supportEmail,
    supportWhatsapp,
    privacyPolicyUrl,
    termsUrl,
  ];
}
