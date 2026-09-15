import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/add_ons_input.dart';
import '../widgets/availability_toggle_row.dart';
import '../widgets/product_image_picker.dart';

/// Add-product form, reached by pushing `AppRoutes.addProductName` (the "+
/// منتج" button on the menu screen). Self-contained: owns its own
/// [Scaffold], [AppBar] and RTL [Directionality].
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

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
      // TODO: save product.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: BrandBackButton(),
          ),
          title: const Text(
            'إضافة منتج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: BrandColors.navy,
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
                  ProductImagePicker(onTap: () {}),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  PrimaryButton(label: 'حفظ المنتج', onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
