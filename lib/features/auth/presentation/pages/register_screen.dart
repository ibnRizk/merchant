import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/params/register_params.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/store_categories/store_categories_cubit.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/auth_step_header.dart';
import '../widgets/delivery_time_unit_field.dart';
import '../widgets/password_form_field.dart';
import '../widgets/register_section_title.dart';
import '../widgets/store_category_field.dart';
import '../widgets/store_image_picker_field.dart';
import '../widgets/store_location_field.dart';

/// Self-registration for a new merchant and store. The account starts as
/// pending until an admin approves it.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  /// The API reads the store name/address from the first translation, so a
  /// single default-locale entry is enough.
  static const String _translationLocale = 'en';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _storeName = TextEditingController();
  final TextEditingController _storeAddress = TextEditingController();
  final TextEditingController _minDelivery = TextEditingController();
  final TextEditingController _maxDelivery = TextEditingController();

  DeliveryTimeType _deliveryTimeType = DeliveryTimeType.min;
  int? _categoryId;
  String? _logoPath;
  String? _coverPhotoPath;
  LatLng? _location;

  /// Shown only after a submit attempt without a category / logo / location.
  bool _showCategoryError = false;
  bool _showLogoError = false;
  bool _showLocationError = false;

  @override
  void dispose() {
    for (final TextEditingController controller in <TextEditingController>[
      _firstName,
      _lastName,
      _email,
      _phone,
      _password,
      _confirmPassword,
      _storeName,
      _storeAddress,
      _minDelivery,
      _maxDelivery,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      Validator.call(value: value, type: ValidatorType.standard);

  String? _integer(String? value) =>
      Validator.call(value: value, type: ValidatorType.numbersOnly);

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return Strings.confirmPasswordError;
    return value == _password.text ? null : Strings.passwordsDoNotMatch;
  }

  String? _validateMaxDelivery(String? value) {
    final String? error = _integer(value);
    if (error != null) return error;
    final int? min = int.tryParse(_minDelivery.text.trim());
    final int max = int.parse(value!.trim());
    return (min != null && max < min) ? Strings.maxDeliveryLessThanMin : null;
  }

  Future<void> _pickLocation() async {
    FocusScope.of(context).unfocus();
    final LatLng? picked = await context.pushNamed<LatLng>(
      AppRoutes.locationPickerName,
      extra: _location,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _location = picked;
      _showLocationError = false;
    });
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final bool fieldsValid = _formKey.currentState!.validate();
    final bool categoryMissing = context
        .read<StoreCategoriesCubit>()
        .isSelectionMissing(_categoryId);
    final String? logoPath = _logoPath;
    final LatLng? location = _location;
    setState(() {
      _showCategoryError = categoryMissing;
      _showLogoError = logoPath == null;
      _showLocationError = location == null;
    });
    if (!fieldsValid ||
        categoryMissing ||
        logoPath == null ||
        location == null) {
      return;
    }

    context.read<RegisterCubit>().register(
      RegisterParams(
        fName: _firstName.text.trim(),
        lName: _lastName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        password: _password.text,
        latitude: location.latitude,
        longitude: location.longitude,
        storeCategoryId: _categoryId,
        minimumDeliveryTime: int.parse(_minDelivery.text.trim()),
        maximumDeliveryTime: int.parse(_maxDelivery.text.trim()),
        deliveryTimeType: _deliveryTimeType,
        translations: <StoreTranslation>[
          StoreTranslation(
            locale: _translationLocale,
            name: _storeName.text.trim(),
            address: _storeAddress.text.trim(),
          ),
        ],
        logoPath: logoPath,
        coverPhotoPath: _coverPhotoPath,
      ),
    );
  }

  void _onStateChanged(BuildContext context, RegisterState state) {
    switch (state) {
      case RegisterSuccess():
        showBrandSnackBar(context, Strings.registrationSubmitted);
        context.pop();
      case RegisterFailure(:final message):
        showBrandSnackBar(context, message, isError: true);
      case RegisterInitial() || RegisterLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: _onStateChanged,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: const AuthAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AuthStepHeader(
                    title: Strings.registerTitle,
                    subtitle: Strings.registerSubtitle,
                  ),
                  ..._ownerSection(),
                  ..._storeSection(),
                  ..._locationSection(),
                  ..._deliverySection(),
                  const SizedBox(height: 32),
                  BlocSelector<RegisterCubit, RegisterState, bool>(
                    selector: (RegisterState state) => state is RegisterLoading,
                    builder: (BuildContext context, bool isLoading) =>
                        PrimaryButton(
                          label: Strings.submitApplication,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _ownerSection() => <Widget>[
    RegisterSectionTitle(Strings.ownerInfoSection),
    _Pair(
      first: AppFormField(
        controller: _firstName,
        label: Strings.firstName,
        validator: _required,
      ),
      second: AppFormField(
        controller: _lastName,
        label: Strings.lastName,
        validator: _required,
      ),
    ),
    const SizedBox(height: 16),
    AppFormField(
      controller: _email,
      label: Strings.email,
      hintText: 'name@example.com',
      keyboardType: TextInputType.emailAddress,
      validator: (String? value) =>
          Validator.call(value: value, type: ValidatorType.email),
    ),
    const SizedBox(height: 16),
    AppFormField(
      controller: _phone,
      label: Strings.mobileNumber,
      hintText: '+20 1X XXXX XXXX',
      keyboardType: TextInputType.phone,
      validator: (String? value) =>
          Validator.call(value: value, type: ValidatorType.phone),
    ),
    const SizedBox(height: 16),
    PasswordFormField(
      controller: _password,
      label: Strings.password,
      validator: (String? value) =>
          Validator.call(value: value, type: ValidatorType.strongPassword),
    ),
    const SizedBox(height: 16),
    PasswordFormField(
      controller: _confirmPassword,
      label: Strings.confirmPassword,
      validator: _validateConfirmPassword,
    ),
  ];

  List<Widget> _storeSection() => <Widget>[
    RegisterSectionTitle(Strings.storeInfoSection),
    AppFormField(
      controller: _storeName,
      label: Strings.storeNameLabel,
      validator: _required,
    ),
    const SizedBox(height: 16),
    BlocBuilder<StoreCategoriesCubit, StoreCategoriesState>(
      builder: (BuildContext context, StoreCategoriesState state) =>
          StoreCategoryField(
            state: state,
            selectedId: _categoryId,
            errorText: _showCategoryError ? Strings.categoryRequired : null,
            onRetry: context.read<StoreCategoriesCubit>().load,
            onChanged: (int id) => setState(() {
              _categoryId = id;
              _showCategoryError = false;
            }),
          ),
    ),
    const SizedBox(height: 16),
    AppFormField(
      controller: _storeAddress,
      label: Strings.addressLabel,
      maxLines: 2,
      validator: _required,
    ),
    const SizedBox(height: 16),
    StoreImagePickerField(
      label: Strings.storeLogo,
      path: _logoPath,
      errorText: _showLogoError ? Strings.logoRequired : null,
      onChanged: (String path) => setState(() {
        _logoPath = path;
        _showLogoError = false;
      }),
    ),
    const SizedBox(height: 16),
    StoreImagePickerField(
      label: Strings.coverPhotoOptional,
      path: _coverPhotoPath,
      height: 160,
      onChanged: (String path) => setState(() => _coverPhotoPath = path),
    ),
  ];

  List<Widget> _locationSection() => <Widget>[
    RegisterSectionTitle(Strings.storeLocationSection),
    StoreLocationField(
      location: _location,
      errorText: _showLocationError ? Strings.locationRequired : null,
      onTap: _pickLocation,
    ),
  ];

  List<Widget> _deliverySection() => <Widget>[
    RegisterSectionTitle(Strings.deliveryTimeSection),
    _Pair(
      first: AppFormField(
        controller: _minDelivery,
        label: Strings.minDeliveryTime,
        keyboardType: TextInputType.number,
        validator: _integer,
      ),
      second: AppFormField(
        controller: _maxDelivery,
        label: Strings.maxDeliveryTime,
        keyboardType: TextInputType.number,
        validator: _validateMaxDelivery,
      ),
    ),
    const SizedBox(height: 16),
    DeliveryTimeUnitField(
      value: _deliveryTimeType,
      onChanged: (DeliveryTimeType type) =>
          setState(() => _deliveryTimeType = type),
    ),
  ];
}

/// Two fields side by side, top-aligned so an error under one doesn't shift
/// the other.
class _Pair extends StatelessWidget {
  const _Pair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }
}
