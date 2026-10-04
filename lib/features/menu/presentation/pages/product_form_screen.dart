import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/field_notice.dart';
import '../../../../core/widgets/image_picker_field.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/catalog_metadata.dart';
import '../../domain/entities/product.dart';
import '../../domain/params/product_params.dart';
import '../cubit/product_form/product_form_cubit.dart';
import '../widgets/availability_toggle_row.dart';

/// Add or edit a product. [initialProduct] (from the list) prefills the
/// form while the full product and the catalog metadata load; `null` means
/// add. Pops with the saved [Product].
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.initialProduct});

  final Product? initialProduct;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int? _categoryId;
  String? _imagePath;
  bool _isAvailable = true;

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final Product? initial = widget.initialProduct;
    if (initial != null) _fillFrom(initial);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fillFrom(Product product) {
    _nameController.text = product.name;
    _priceController.text = formatPrice(product.price);
    _descriptionController.text = product.description;
    _categoryId = product.category?.id;
    _isAvailable = product.isActive;
  }

  String? _required(String? value) =>
      Validator.call(value: value ?? '', type: ValidatorType.standard);

  String? _validatePrice(String? value) {
    final double? price = parsePrice(value ?? '');
    return (price == null || price < 0.01) ? Strings.invalidPrice : null;
  }

  String? _validateCategory(int? value) =>
      value == null ? Strings.fieldRequired : null;

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final int? categoryId = _categoryId;
    if (categoryId == null) {
      // Only reachable when the store has no categories: there's no
      // dropdown to validate, and the API rejects a product without one.
      showBrandSnackBar(context, Strings.noProductCategories, isError: true);
      return;
    }
    context.read<ProductFormCubit>().save(
      ProductDraft(
        name: _nameController.text,
        description: _descriptionController.text,
        price: parsePrice(_priceController.text)!,
        categoryId: categoryId,
        imagePath: _imagePath,
      ),
      isAvailable: _isAvailable,
    );
  }

  void _onStateChanged(BuildContext context, ProductFormState state) {
    switch (state) {
      case ProductFormEditing(:final product?):
        // The full product replaces the list's copy once it arrives.
        setState(() => _fillFrom(product));
      case ProductFormSaved(:final saved, :final statusUpdateFailed):
        showBrandSnackBar(
          context,
          statusUpdateFailed
              ? Strings.productSavedStatusFailed
              : (_isEditing ? Strings.productUpdated : Strings.productCreated),
          isError: statusUpdateFailed,
          duration: Duration(seconds: statusUpdateFailed ? 5 : 2),
        );
        context.pop<Product>(saved);
      case ProductFormUnchanged():
        showBrandSnackBar(context, Strings.noChangesToSave);
      case ProductFormSaveFailure(:final message):
        showBrandSnackBar(context, message, isError: true);
      case ProductFormEditing() ||
          ProductFormLoading() ||
          ProductFormLoadFailure() ||
          ProductFormSaving():
        break;
    }
  }

  /// Only loading → ready → failure changes the layout; save attempts don't.
  static bool _phaseChanged(ProductFormState previous, ProductFormState next) =>
      !(previous is ProductFormReady && next is ProductFormReady);

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    // Read here, not in the builder below: `select` must run in this
    // element's own build.
    final String currency = context.currency;
    return BlocListener<ProductFormCubit, ProductFormState>(
      listener: _onStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: const Padding(
            padding: EdgeInsetsDirectional.only(start: 16),
            child: BrandBackButton(),
          ),
          title: Text(
            _isEditing ? Strings.editProduct : Strings.addProductTitle,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ProductFormCubit, ProductFormState>(
            buildWhen: _phaseChanged,
            builder: (BuildContext context, ProductFormState state) =>
                switch (state) {
                  ProductFormLoading() => const SectionLoadingView(),
                  ProductFormLoadFailure(:final message) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: RetryErrorView(
                      message: message,
                      onRetry: context.read<ProductFormCubit>().retry,
                    ),
                  ),
                  ProductFormReady(:final metadata, :final product) =>
                    _buildForm(metadata, product, currency),
                },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    CatalogMetadata metadata,
    Product? product,
    String currency,
  ) {
    final AppColors colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ImagePickerField(
              label: Strings.productImage,
              path: _imagePath,
              imageUrl: product?.imageUrl,
              height: 180,
              onChanged: (String path) => setState(() => _imagePath = path),
            ),
            const SizedBox(height: 20),
            AppFormField(
              label: Strings.productName,
              controller: _nameController,
              validator: _required,
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: Strings.productPrice,
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              suffixText: currency.isEmpty ? null : currency,
              validator: _validatePrice,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: Strings.productCategory,
              child: metadata.categories.isEmpty
                  ? FieldNotice(
                      icon: Icons.info_outline_rounded,
                      iconColor: colors.info,
                      text: Strings.noProductCategories,
                    )
                  : AppDropdownField<int>(
                      options: <DropdownOption<int>>[
                        for (final CatalogOption category
                            in metadata.categories)
                          (value: category.id, label: category.name),
                      ],
                      value: metadata.hasCategory(_categoryId)
                          ? _categoryId
                          : null,
                      hintText: Strings.selectProductCategory,
                      prefixIcon: Icons.category_outlined,
                      validator: _validateCategory,
                      onChanged: (int id) => setState(() => _categoryId = id),
                    ),
            ),
            const SizedBox(height: 16),
            AppFormField(
              label: Strings.productDescription,
              controller: _descriptionController,
              maxLines: 4,
              validator: _required,
            ),
            const SizedBox(height: 16),
            AvailabilityToggleRow(
              label: _isAvailable ? Strings.available : Strings.unavailable,
              value: _isAvailable,
              onChanged: (bool value) => setState(() => _isAvailable = value),
            ),
            const SizedBox(height: 28),
            BlocSelector<ProductFormCubit, ProductFormState, bool>(
              selector: (ProductFormState state) => state is ProductFormSaving,
              builder: (_, bool isSaving) => PrimaryButton(
                label: _isEditing ? Strings.saveChanges : Strings.saveProduct,
                isLoading: isSaving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
