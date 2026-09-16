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

  // --- Home ---
  static const String _goodMorning = 'good_morning';
  static String get goodMorning => _goodMorning.tr;

  static const String _storeOpen = 'store_open';
  static String get storeOpen => _storeOpen.tr;

  static const String _storeClosed = 'store_closed';
  static String get storeClosed => _storeClosed.tr;

  static const String _todaysOrders = 'todays_orders';
  static String get todaysOrders => _todaysOrders.tr;

  static const String _newOrders = 'new_orders';
  static String get newOrders => _newOrders.tr;

  static const String _todaysRevenue = 'todays_revenue';
  static String get todaysRevenue => _todaysRevenue.tr;

  static const String _processingOrders = 'processing_orders';
  static String get processingOrders => _processingOrders.tr;

  static const String _currencySar = 'currency_sar';
  static String get currencySar => _currencySar.tr;

  static const String _needsAttention = 'needs_attention';
  static String get needsAttention => _needsAttention.tr;

  static const String _viewAll = 'view_all';
  static String get viewAll => _viewAll.tr;

  static const String _waitingForAcceptance = 'waiting_for_acceptance';
  static String get waitingForAcceptance => _waitingForAcceptance.tr;

  static const String _openOrders = 'open_orders';
  static String get openOrders => _openOrders.tr;

  static const String _processingOrdersTitle = 'processing_orders_title';
  static String get processingOrdersTitle => _processingOrdersTitle.tr;

  static const String _notifyDriverWhenReady = 'notify_driver_when_ready';
  static String get notifyDriverWhenReady => _notifyDriverWhenReady.tr;

  static const String _view = 'view';
  static String get view => _view.tr;

  // --- Orders ---
  static const String _orderHistory = 'order_history';
  static String get orderHistory => _orderHistory.tr;

  static const String _export = 'export';
  static String get export => _export.tr;

  static const String _searchOrderNumber = 'search_order_number';
  static String get searchOrderNumber => _searchOrderNumber.tr;

  static const String _allOrders = 'all_orders';
  static String get allOrders => _allOrders.tr;

  static const String _completed = 'completed';
  static String get completed => _completed.tr;

  static const String _cancelled = 'cancelled';
  static String get cancelled => _cancelled.tr;

  static const String _today = 'today';
  static String get today => _today.tr;

  static const String _yesterday = 'yesterday';
  static String get yesterday => _yesterday.tr;

  static const String _itemsPlural = 'items_plural';
  static String get itemsPlural => _itemsPlural.tr;

  static const String _itemSingular = 'item_singular';
  static String get itemSingular => _itemSingular.tr;

  static const String _delivered = 'delivered';
  static String get delivered => _delivered.tr;

  static const String _cancelledStatus = 'cancelled_status';
  static String get cancelledStatus => _cancelledStatus.tr;

  static const String _processingStatus = 'processing_status';
  static String get processingStatus => _processingStatus.tr;

  static const String _newStatus = 'new_status';
  static String get newStatus => _newStatus.tr;

  static const String _newOrdersTitle = 'new_orders_title';
  static String get newOrdersTitle => _newOrdersTitle.tr;

  static const String _waiting = 'waiting';
  static String get waiting => _waiting.tr;

  static const String _directFromCustomer = 'direct_from_customer';
  static String get directFromCustomer => _directFromCustomer.tr;

  static const String _managementMonitors = 'management_monitors';
  static String get managementMonitors => _managementMonitors.tr;

  static const String _customerNote = 'customer_note';
  static String get customerNote => _customerNote.tr;

  static const String _acceptAndStart = 'accept_and_start';
  static String get acceptAndStart => _acceptAndStart.tr;

  static const String _rejectOrder = 'reject_order';
  static String get rejectOrder => _rejectOrder.tr;

  static const String _afterPressing = 'after_pressing';
  static String get afterPressing => _afterPressing.tr;

  static const String _readyForPickupQuoted = 'ready_for_pickup_quoted';
  static String get readyForPickupQuoted => _readyForPickupQuoted.tr;

  static const String _systemWillNotifyDriver = 'system_will_notify_driver';
  static String get systemWillNotifyDriver => _systemWillNotifyDriver.tr;

  static const String _customerPrefix = 'customer_prefix';
  static String get customerPrefix => _customerPrefix.tr;

  // --- Menu ---
  static const String _menuManagement = 'menu_management';
  static String get menuManagement => _menuManagement.tr;

  static const String _addProduct = 'add_product';
  static String get addProduct => _addProduct.tr;

  static const String _searchProduct = 'search_product';
  static String get searchProduct => _searchProduct.tr;

  static const String _available = 'available';
  static String get available => _available.tr;

  static const String _unavailable = 'unavailable';
  static String get unavailable => _unavailable.tr;

  static const String _additions = 'additions';
  static String get additions => _additions.tr;

  static const String _size = 'size';
  static String get size => _size.tr;

  static const String _editProduct = 'edit_product';
  static String get editProduct => _editProduct.tr;

  static const String _tip = 'tip';
  static String get tip => _tip.tr;

  static const String _pauseProductTip = 'pause_product_tip';
  static String get pauseProductTip => _pauseProductTip.tr;

  // --- Hours ---
  static const String _workingHours = 'working_hours';
  static String get workingHours => _workingHours.tr;

  static const String _localTimeNote = 'local_time_note';
  static String get localTimeNote => _localTimeNote.tr;

  static const String _saveWorkingHours = 'save_working_hours';
  static String get saveWorkingHours => _saveWorkingHours.tr;

  static const String _saturday = 'saturday';
  static String get saturday => _saturday.tr;

  static const String _sunday = 'sunday';
  static String get sunday => _sunday.tr;

  static const String _monday = 'monday';
  static String get monday => _monday.tr;

  static const String _tuesday = 'tuesday';
  static String get tuesday => _tuesday.tr;

  static const String _wednesday = 'wednesday';
  static String get wednesday => _wednesday.tr;

  static const String _thursday = 'thursday';
  static String get thursday => _thursday.tr;

  static const String _friday = 'friday';
  static String get friday => _friday.tr;

  static const String _closed = 'closed';
  static String get closed => _closed.tr;

  // --- Nav ---
  static const String _navHome = 'nav_home';
  static String get navHome => _navHome.tr;

  static const String _navOrders = 'nav_orders';
  static String get navOrders => _navOrders.tr;

  static const String _navMenu = 'nav_menu';
  static String get navMenu => _navMenu.tr;

  static const String _navHours = 'nav_hours';
  static String get navHours => _navHours.tr;

  static const String _navProfile = 'nav_profile';
  static String get navProfile => _navProfile.tr;

  // --- Auth ---
  static const String _resendCode = 'resend_code';
  static String get resendCode => _resendCode.tr;

  static const String _mobileNumber = 'mobile_number';
  static String get mobileNumber => _mobileNumber.tr;

  static const String _username = 'username';
  static String get username => _username.tr;

  static const String _welcome = 'welcome';
  static String get welcome => _welcome.tr;

  static const String _loginToManageStore = 'login_to_manage_store';
  static String get loginToManageStore => _loginToManageStore.tr;

  static const String _enterNewPassword = 'enter_new_password';
  static String get enterNewPassword => _enterNewPassword.tr;

  static const String _confirmPasswordError = 'confirm_password_error';
  static String get confirmPasswordError => _confirmPasswordError.tr;

  static const String _passwordUpdatedSuccess = 'password_updated_success';
  static String get passwordUpdatedSuccess => _passwordUpdatedSuccess.tr;

  static const String _newPassword = 'new_password';
  static String get newPassword => _newPassword.tr;

  static const String _enterNewPasswordSubtitle = 'enter_new_password_subtitle';
  static String get enterNewPasswordSubtitle => _enterNewPasswordSubtitle.tr;

  static const String _confirmPassword = 'confirm_password';
  static String get confirmPassword => _confirmPassword.tr;

  static const String _setPassword = 'set_password';
  static String get setPassword => _setPassword.tr;

  static const String _enterFullCode = 'enter_full_code';
  static String get enterFullCode => _enterFullCode.tr;

  static const String _verificationCode = 'verification_code';
  static String get verificationCode => _verificationCode.tr;

  static const String _enter4DigitCode = 'enter_4_digit_code';
  static String get enter4DigitCode => _enter4DigitCode.tr;

  static const String _codeResent = 'code_resent';
  static String get codeResent => _codeResent.tr;

  static const String _enterMobileNumber = 'enter_mobile_number';
  static String get enterMobileNumber => _enterMobileNumber.tr;

  static const String _enterUsername = 'enter_username';
  static String get enterUsername => _enterUsername.tr;

  static const String _enterPassword = 'enter_password';
  static String get enterPassword => _enterPassword.tr;

  static const String _password = 'password';
  static String get password => _password.tr;

  static const String _login = 'login';
  static String get login => _login.tr;

  static const String _forgotPassword = 'forgot_password';
  static String get forgotPassword => _forgotPassword.tr;

  static const String _enterMobileToReset = 'enter_mobile_to_reset';
  static String get enterMobileToReset => _enterMobileToReset.tr;

  static const String _sendVerificationCode = 'send_verification_code';
  static String get sendVerificationCode => _sendVerificationCode.tr;

  static const String _logout = 'logout';
  static String get logout => _logout.tr;
}
