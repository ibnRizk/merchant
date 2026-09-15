import 'package:flutter/material.dart';

import '../utils/values/brand_colors.dart';
import 'labeled_field.dart';

/// Labeled, white rounded form field shared by the profile and add-product
/// forms (single-line inputs and multi-line text areas alike).
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.valueColor = BrandColors.navy,
    this.suffixText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final Color valueColor;
  final String? suffixText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
        decoration: InputDecoration(
          suffixText: suffixText,
          suffixStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BrandColors.textGray,
          ),
          errorStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: BrandColors.cancelledText,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 14 : 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BrandColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BrandColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BrandColors.navy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BrandColors.cancelledText),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BrandColors.cancelledText, width: 1.5),
          ),
        ),
      ),
    );
  }
}
