import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/add_ons_input.dart';
import '../widgets/availability_toggle_row.dart';
import '../widgets/product_card.dart' show ProductEntry;
import '../widgets/product_image_picker.dart';

/// Add/edit-product form, reached by pushing `AppRoutes.addProductName`
/// (the "+ منتج" button, or a product's "تعديل المنتج"/kebab menu, which
/// pass an [existingProduct] to prefill). Self-contained: owns its own
/// [Scaffold], [AppBar] and RTL [Directionality].
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key, this.existingProduct});

  final ProductEntry? existingProduct;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> _addOns = <String>[];
  bool _isAvailable = true;

  bool get _isEditing => widget.existingProduct != null;

  @override
  void initState() {
    super.initState();
    final ProductEntry? existing = widget.existingProduct;
    if (existing != null) {
      _nameController.text = existing.name;
      _priceController.text = existing.price.replaceAll('ر.س', '').trim();
      _isAvailable = existing.isAvailable;
      _addOns = List<String>.of(existing.addOns);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال السعر';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'أدخل رقماً صحيحاً';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showBrandSnackBar(
        context,
        _isEditing ? 'تم حفظ تعديلات المنتج' : 'تمت إضافة المنتج بنجاح',
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: BrandBackButton(),
        ),
        title: Text(
          _isEditing ? 'تعديل منتج' : 'إضافة منتج',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ProductImagePicker(
                  onTap: () => showBrandSnackBar(
                    context,
                    'ميزة اختيار الصورة قيد التطوير',
                  ),
                ),
                const SizedBox(height: 24),
                AppFormField(
                  label: 'اسم المنتج',
                  controller: _nameController,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'السعر',
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffixText: 'ر.س',
                  validator: _priceValidator,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  label: 'وصف المنتج',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'الإضافات',
                  child: AddOnsInput(
                    initialTags: _addOns,
                    onChanged: (List<String> tags) => _addOns = tags,
                  ),
                ),
                const SizedBox(height: 16),
                AvailabilityToggleRow(
                  label: _isAvailable ? 'متوفر' : 'غير متوفر',
                  value: _isAvailable,
                  onChanged: (bool value) =>
                      setState(() => _isAvailable = value),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: _isEditing ? 'حفظ التعديلات' : 'حفظ المنتج',
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
