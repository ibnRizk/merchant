import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';
import 'labeled_field.dart';

/// Labeled, surface-colored rounded form field shared by the profile and
/// add-product forms (single-line inputs and multi-line text areas alike).
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.valueColor,
    this.suffixText,
    this.validator,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;

  /// Defaults to [AppColors.textPrimary] when omitted — kept nullable
  /// because a context-aware default can't be a compile-time constant.
  final Color? valueColor;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        textAlign: TextAlign.start,
        textDirection:
            keyboardType == TextInputType.phone ? TextDirection.ltr : null,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: valueColor ?? colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: colors.textSecondary,
          ),
          suffixText: suffixText,
          suffixIcon: suffixIcon,
          suffixStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
          errorStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: colors.error,
          ),
          filled: true,
          fillColor: colors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 14 : 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.secondary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}
