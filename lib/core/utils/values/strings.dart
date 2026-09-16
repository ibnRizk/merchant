import '../../../config/locale/app_localizations.dart';

/// Translation-key wrappers. Every getter must have a matching key in
/// `lang/en.json` **and** `lang/ar.json`, or it renders `"<key> not found"`.
///
/// Keep this file and the JSON files in lockstep — that is the whole contract.
abstract class Strings {
  // --- App ---
  static const String _appName = 'app_name';
  static String get appName => _appName.tr;

  // --- Common actions ---
  static const String _ok = 'ok';
  static String get ok => _ok.tr;

  static const String _cancel = 'cancel';
  static String get cancel => _cancel.tr;

  static const String _confirm = 'confirm';
  static String get confirm => _confirm.tr;

  static const String _retry = 'retry';
  static String get retry => _retry.tr;

  static const String _save = 'save';
  static String get save => _save.tr;

  static const String _delete = 'delete';
  static String get delete => _delete.tr;

  static const String _search = 'search';
  static String get search => _search.tr;

  static const String _loading = 'loading';
  static String get loading => _loading.tr;

  // --- Errors / empty states ---
  static const String _noInternetConnection = 'no_internet_connection';
  static String get noInternetConnection => _noInternetConnection.tr;

  static const String _somethingWentWrong = 'something_went_wrong';
  static String get somethingWentWrong => _somethingWentWrong.tr;

  static const String _requestCancelled = 'request_cancelled';
  static String get requestCancelled => _requestCancelled.tr;

  static const String _noDataFound = 'no_data_found';
  static String get noDataFound => _noDataFound.tr;

  static const String _noResults = 'no_results';
  static String get noResults => _noResults.tr;

  // --- Settings ---
  static const String _language = 'language';
  static String get language => _language.tr;

  static const String _english = 'english';
  static String get english => _english.tr;

  static const String _arabic = 'arabic';
  static String get arabic => _arabic.tr;

  static const String _settings = 'settings';
  static String get settings => _settings.tr;

  static const String _theme = 'theme';
  static String get theme => _theme.tr;

  static const String _lightMode = 'light_mode';
  static String get lightMode => _lightMode.tr;

  static const String _darkMode = 'dark_mode';
  static String get darkMode => _darkMode.tr;

  static const String _systemMode = 'system_mode';
  static String get systemMode => _systemMode.tr;

  // --- Validation ---
  static const String _fieldRequired = 'field_required';
  static String get fieldRequired => _fieldRequired.tr;

  static const String _invalidEmail = 'invalid_email';
  static String get invalidEmail => _invalidEmail.tr;

  static const String _invalidPhone = 'invalid_phone';
  static String get invalidPhone => _invalidPhone.tr;

  static const String _invalidName = 'invalid_name';
  static String get invalidName => _invalidName.tr;

  static const String _invalidNumbers = 'invalid_numbers';
  static String get invalidNumbers => _invalidNumbers.tr;

  static const String _passwordTooShort = 'password_too_short';
  static String get passwordTooShort => _passwordTooShort.tr;

  static const String _passwordsDoNotMatch = 'passwords_do_not_match';
  static String get passwordsDoNotMatch => _passwordsDoNotMatch.tr;

  // --- Profile screen ---
  static const String _profileTitle = 'profile_title';
  static String get profileTitle => _profileTitle.tr;

  static const String _storeNameLabel = 'store_name_label';
  static String get storeNameLabel => _storeNameLabel.tr;

  static const String _categoryLabel = 'category_label';
  static String get categoryLabel => _categoryLabel.tr;

  static const String _storeDescriptionLabel = 'store_description_label';
  static String get storeDescriptionLabel => _storeDescriptionLabel.tr;

  static const String _contactNumberLabel = 'contact_number_label';
  static String get contactNumberLabel => _contactNumberLabel.tr;

  static const String _addressLabel = 'address_label';
  static String get addressLabel => _addressLabel.tr;

  static const String _categoryRestaurants = 'category_restaurants';
  static String get categoryRestaurants => _categoryRestaurants.tr;

  static const String _categoryCafes = 'category_cafes';
  static String get categoryCafes => _categoryCafes.tr;

  static const String _categorySweets = 'category_sweets';
  static String get categorySweets => _categorySweets.tr;

  static const String _categoryGrocery = 'category_grocery';
  static String get categoryGrocery => _categoryGrocery.tr;

  static const String _freeTrialBanner = 'free_trial_banner';
  static String get freeTrialBanner => _freeTrialBanner.tr;

  static const String _mapPickerComingSoon = 'map_picker_coming_soon';
  static String get mapPickerComingSoon => _mapPickerComingSoon.tr;

  static const String _profileSavedSuccess = 'profile_saved_success';
  static String get profileSavedSuccess => _profileSavedSuccess.tr;
}
