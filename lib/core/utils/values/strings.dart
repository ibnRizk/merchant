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

  static const String _noChangesToSave = 'no_changes_to_save';
  static String get noChangesToSave => _noChangesToSave.tr;

  static const String _storePhoneLabel = 'store_phone_label';
  static String get storePhoneLabel => _storePhoneLabel.tr;

  static const String _storeEmailLabel = 'store_email_label';
  static String get storeEmailLabel => _storeEmailLabel.tr;

  static const String _chooseAppLanguage = 'choose_app_language';
  static String get chooseAppLanguage => _chooseAppLanguage.tr;

  static const String _logoutConfirmTitle = 'logout_confirm_title';
  static String get logoutConfirmTitle => _logoutConfirmTitle.tr;

  static const String _logoutConfirmMessage = 'logout_confirm_message';
  static String get logoutConfirmMessage => _logoutConfirmMessage.tr;

  // --- Home ---
  static const String _goodMorning = 'good_morning';
  static String get goodMorning => _goodMorning.tr;

  static const String _goodEvening = 'good_evening';
  static String get goodEvening => _goodEvening.tr;

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

  static const String _nothingNeedsAttention = 'nothing_needs_attention';
  static String get nothingNeedsAttention => _nothingNeedsAttention.tr;

  // --- Orders ---
  static const String _orderHistory = 'order_history';
  static String get orderHistory => _orderHistory.tr;

  static const String _export = 'export';
  static String get export => _export.tr;

  static const String _exportComingSoon = 'export_coming_soon';
  static String get exportComingSoon => _exportComingSoon.tr;

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

  static const String _activeOrdersTitle = 'active_orders_title';
  static String get activeOrdersTitle => _activeOrdersTitle.tr;

  static const String _ordersCount = 'orders_count';
  static String get ordersCount => _ordersCount.tr;

  static const String _acceptOrder = 'accept_order';
  static String get acceptOrder => _acceptOrder.tr;

  static const String _startPreparing = 'start_preparing';
  static String get startPreparing => _startPreparing.tr;

  static const String _viewDetails = 'view_details';
  static String get viewDetails => _viewDetails.tr;

  static const String _loadMore = 'load_more';
  static String get loadMore => _loadMore.tr;

  static const String _noNewOrders = 'no_new_orders';
  static String get noNewOrders => _noNewOrders.tr;

  static const String _noActiveOrders = 'no_active_orders';
  static String get noActiveOrders => _noActiveOrders.tr;

  static const String _noOrdersYet = 'no_orders_yet';
  static String get noOrdersYet => _noOrdersYet.tr;

  static const String _orderAccepted = 'order_accepted';
  static String get orderAccepted => _orderAccepted.tr;

  static const String _orderRejected = 'order_rejected';
  static String get orderRejected => _orderRejected.tr;

  static const String _orderUpdated = 'order_updated';
  static String get orderUpdated => _orderUpdated.tr;

  static const String _orderConflict = 'order_conflict';
  static String get orderConflict => _orderConflict.tr;

  static const String _orderDetailsTitle = 'order_details_title';
  static String get orderDetailsTitle => _orderDetailsTitle.tr;

  static const String _orderItems = 'order_items';
  static String get orderItems => _orderItems.tr;

  static const String _deliveryFee = 'delivery_fee';
  static String get deliveryFee => _deliveryFee.tr;

  static const String _orderTotal = 'order_total';
  static String get orderTotal => _orderTotal.tr;

  static const String _customerLabel = 'customer_label';
  static String get customerLabel => _customerLabel.tr;

  static const String _deliveryAddressLabel = 'delivery_address_label';
  static String get deliveryAddressLabel => _deliveryAddressLabel.tr;

  static const String _paymentMethodLabel = 'payment_method_label';
  static String get paymentMethodLabel => _paymentMethodLabel.tr;

  static const String _paymentCash = 'payment_cash';
  static String get paymentCash => _paymentCash.tr;

  static const String _paymentOnline = 'payment_online';
  static String get paymentOnline => _paymentOnline.tr;

  static const String _rejectOrderTitle = 'reject_order_title';
  static String get rejectOrderTitle => _rejectOrderTitle.tr;

  static const String _rejectReasonLabel = 'reject_reason_label';
  static String get rejectReasonLabel => _rejectReasonLabel.tr;

  static const String _rejectReasonItemUnavailable =
      'reject_reason_item_unavailable';
  static String get rejectReasonItemUnavailable =>
      _rejectReasonItemUnavailable.tr;

  static const String _rejectReasonStoreBusy = 'reject_reason_store_busy';
  static String get rejectReasonStoreBusy => _rejectReasonStoreBusy.tr;

  static const String _rejectReasonStoreClosing = 'reject_reason_store_closing';
  static String get rejectReasonStoreClosing => _rejectReasonStoreClosing.tr;

  static const String _rejectReasonOther = 'reject_reason_other';
  static String get rejectReasonOther => _rejectReasonOther.tr;

  static const String _rejectNoteHint = 'reject_note_hint';
  static String get rejectNoteHint => _rejectNoteHint.tr;

  // --- Order statuses ---
  static const String _statusAccepted = 'status_accepted';
  static String get statusAccepted => _statusAccepted.tr;

  static const String _statusPreparing = 'status_preparing';
  static String get statusPreparing => _statusPreparing.tr;

  static const String _statusReadyForPickup = 'status_ready_for_pickup';
  static String get statusReadyForPickup => _statusReadyForPickup.tr;

  static const String _statusDispatching = 'status_dispatching';
  static String get statusDispatching => _statusDispatching.tr;

  static const String _statusDriverAssigned = 'status_driver_assigned';
  static String get statusDriverAssigned => _statusDriverAssigned.tr;

  static const String _statusPickedUp = 'status_picked_up';
  static String get statusPickedUp => _statusPickedUp.tr;

  static const String _statusOutForDelivery = 'status_out_for_delivery';
  static String get statusOutForDelivery => _statusOutForDelivery.tr;

  static const String _statusRejected = 'status_rejected';
  static String get statusRejected => _statusRejected.tr;

  static const String _statusAssignmentFailed = 'status_assignment_failed';
  static String get statusAssignmentFailed => _statusAssignmentFailed.tr;

  static const String _statusRefunded = 'status_refunded';
  static String get statusRefunded => _statusRefunded.tr;

  static const String _statusUnknown = 'status_unknown';
  static String get statusUnknown => _statusUnknown.tr;

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

  static const String _addProductTitle = 'add_product_title';
  static String get addProductTitle => _addProductTitle.tr;

  static const String _productImage = 'product_image';
  static String get productImage => _productImage.tr;

  static const String _productName = 'product_name';
  static String get productName => _productName.tr;

  static const String _productPrice = 'product_price';
  static String get productPrice => _productPrice.tr;

  static const String _productDescription = 'product_description';
  static String get productDescription => _productDescription.tr;

  static const String _productCategory = 'product_category';
  static String get productCategory => _productCategory.tr;

  static const String _selectProductCategory = 'select_product_category';
  static String get selectProductCategory => _selectProductCategory.tr;

  static const String _noProductCategories = 'no_product_categories';
  static String get noProductCategories => _noProductCategories.tr;

  static const String _invalidPrice = 'invalid_price';
  static String get invalidPrice => _invalidPrice.tr;

  static const String _saveProduct = 'save_product';
  static String get saveProduct => _saveProduct.tr;

  static const String _saveChanges = 'save_changes';
  static String get saveChanges => _saveChanges.tr;

  static const String _productCreated = 'product_created';
  static String get productCreated => _productCreated.tr;

  static const String _productUpdated = 'product_updated';
  static String get productUpdated => _productUpdated.tr;

  static const String _productSavedStatusFailed = 'product_saved_status_failed';
  static String get productSavedStatusFailed => _productSavedStatusFailed.tr;

  static const String _deleteProduct = 'delete_product';
  static String get deleteProduct => _deleteProduct.tr;

  static const String _deleteProductConfirmTitle =
      'delete_product_confirm_title';
  static String get deleteProductConfirmTitle =>
      _deleteProductConfirmTitle.tr;

  static const String _deleteProductConfirmMessage =
      'delete_product_confirm_message';
  static String get deleteProductConfirmMessage =>
      _deleteProductConfirmMessage.tr;

  static const String _productDeleted = 'product_deleted';
  static String get productDeleted => _productDeleted.tr;

  static const String _productLinkedToOrders = 'product_linked_to_orders';
  static String get productLinkedToOrders => _productLinkedToOrders.tr;

  static const String _noProductsYet = 'no_products_yet';
  static String get noProductsYet => _noProductsYet.tr;

  static const String _noProductsHint = 'no_products_hint';
  static String get noProductsHint => _noProductsHint.tr;

  // --- Hours ---
  static const String _workingHours = 'working_hours';
  static String get workingHours => _workingHours.tr;

  static const String _localTimeNote = 'local_time_note';
  static String get localTimeNote => _localTimeNote.tr;

  static const String _saveWorkingHours = 'save_working_hours';
  static String get saveWorkingHours => _saveWorkingHours.tr;

  static const String _workingHoursSaved = 'working_hours_saved';
  static String get workingHoursSaved => _workingHoursSaved.tr;

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

  static const String _codeResent = 'code_resent';
  static String get codeResent => _codeResent.tr;

  static const String _enterPassword = 'enter_password';
  static String get enterPassword => _enterPassword.tr;

  static const String _password = 'password';
  static String get password => _password.tr;

  static const String _login = 'login';
  static String get login => _login.tr;

  static const String _forgotPassword = 'forgot_password';
  static String get forgotPassword => _forgotPassword.tr;

  static const String _sendVerificationCode = 'send_verification_code';
  static String get sendVerificationCode => _sendVerificationCode.tr;

  static const String _logout = 'logout';
  static String get logout => _logout.tr;

  // --- Auth: email login, registration, approval ---
  static const String _email = 'email';
  static String get email => _email.tr;

  static const String _enterEmail = 'enter_email';
  static String get enterEmail => _enterEmail.tr;

  static const String _enterEmailToReset = 'enter_email_to_reset';
  static String get enterEmailToReset => _enterEmailToReset.tr;

  static const String _enterCodeSentToEmail = 'enter_code_sent_to_email';
  static String get enterCodeSentToEmail => _enterCodeSentToEmail.tr;

  static const String _noAccount = 'no_account';
  static String get noAccount => _noAccount.tr;

  static const String _createStoreAccount = 'create_store_account';
  static String get createStoreAccount => _createStoreAccount.tr;

  static const String _registerTitle = 'register_title';
  static String get registerTitle => _registerTitle.tr;

  static const String _registerSubtitle = 'register_subtitle';
  static String get registerSubtitle => _registerSubtitle.tr;

  static const String _ownerInfoSection = 'owner_info_section';
  static String get ownerInfoSection => _ownerInfoSection.tr;

  static const String _firstName = 'first_name';
  static String get firstName => _firstName.tr;

  static const String _lastName = 'last_name';
  static String get lastName => _lastName.tr;

  static const String _storeInfoSection = 'store_info_section';
  static String get storeInfoSection => _storeInfoSection.tr;

  static const String _storeLocationSection = 'store_location_section';
  static String get storeLocationSection => _storeLocationSection.tr;

  static const String _selectCategory = 'select_category';
  static String get selectCategory => _selectCategory.tr;

  static const String _categoryRequired = 'category_required';
  static String get categoryRequired => _categoryRequired.tr;

  static const String _noCategoriesAvailable = 'no_categories_available';
  static String get noCategoriesAvailable => _noCategoriesAvailable.tr;

  static const String _categoryManagedByAdmin = 'category_managed_by_admin';
  static String get categoryManagedByAdmin => _categoryManagedByAdmin.tr;

  static const String _categoryNotSet = 'category_not_set';
  static String get categoryNotSet => _categoryNotSet.tr;

  static const String _deliveryTimeSection = 'delivery_time_section';
  static String get deliveryTimeSection => _deliveryTimeSection.tr;

  static const String _minDeliveryTime = 'min_delivery_time';
  static String get minDeliveryTime => _minDeliveryTime.tr;

  static const String _maxDeliveryTime = 'max_delivery_time';
  static String get maxDeliveryTime => _maxDeliveryTime.tr;

  static const String _deliveryTimeUnit = 'delivery_time_unit';
  static String get deliveryTimeUnit => _deliveryTimeUnit.tr;

  static const String _unitMinutes = 'unit_minutes';
  static String get unitMinutes => _unitMinutes.tr;

  static const String _unitHours = 'unit_hours';
  static String get unitHours => _unitHours.tr;

  static const String _unitDays = 'unit_days';
  static String get unitDays => _unitDays.tr;

  static const String _storeLogo = 'store_logo';
  static String get storeLogo => _storeLogo.tr;

  static const String _coverPhotoOptional = 'cover_photo_optional';
  static String get coverPhotoOptional => _coverPhotoOptional.tr;

  static const String _tapToChooseImage = 'tap_to_choose_image';
  static String get tapToChooseImage => _tapToChooseImage.tr;

  static const String _logoRequired = 'logo_required';
  static String get logoRequired => _logoRequired.tr;

  static const String _maxDeliveryLessThanMin = 'max_delivery_less_than_min';
  static String get maxDeliveryLessThanMin => _maxDeliveryLessThanMin.tr;

  static const String _passwordRequirements = 'password_requirements';
  static String get passwordRequirements => _passwordRequirements.tr;

  static const String _invalidNumber = 'invalid_number';
  static String get invalidNumber => _invalidNumber.tr;

  static const String _submitApplication = 'submit_application';
  static String get submitApplication => _submitApplication.tr;

  static const String _registrationSubmitted = 'registration_submitted';
  static String get registrationSubmitted => _registrationSubmitted.tr;

  static const String _accountPendingTitle = 'account_pending_title';
  static String get accountPendingTitle => _accountPendingTitle.tr;

  static const String _accountPendingBody = 'account_pending_body';
  static String get accountPendingBody => _accountPendingBody.tr;

  static const String _accountRejectedTitle = 'account_rejected_title';
  static String get accountRejectedTitle => _accountRejectedTitle.tr;

  static const String _accountRejectedBody = 'account_rejected_body';
  static String get accountRejectedBody => _accountRejectedBody.tr;

  static const String _backToLogin = 'back_to_login';
  static String get backToLogin => _backToLogin.tr;

  static const String _pickStoreLocation = 'pick_store_location';
  static String get pickStoreLocation => _pickStoreLocation.tr;

  static const String _moveMapToPlacePin = 'move_map_to_place_pin';
  static String get moveMapToPlacePin => _moveMapToPlacePin.tr;

  static const String _confirmLocation = 'confirm_location';
  static String get confirmLocation => _confirmLocation.tr;

  static const String _locationRequired = 'location_required';
  static String get locationRequired => _locationRequired.tr;
}
