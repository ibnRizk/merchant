import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ssm_merchant/config/locale/app_localizations.dart';
import 'package:ssm_merchant/injection_container.dart';

/// Registers English [AppLocalizations] so `Strings.*` resolves in unit
/// tests, as `AppLocalizationsDelegate.load` does in the app. Call from
/// `setUpAll`.
Future<AppLocalizations> registerTestLocalizations() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (ServiceLocator.instance.isRegistered<AppLocalizations>()) {
    return appLocalizations;
  }
  final AppLocalizations localizations = AppLocalizations(const Locale('en'));
  await localizations.load(locale: const Locale('en'));
  ServiceLocator.injectAppLocalizations(localizations);
  return localizations;
}
