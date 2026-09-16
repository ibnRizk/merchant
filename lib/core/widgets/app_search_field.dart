import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Rounded search field shared by list screens (order history, menu
/// management, ...).
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13.5,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.5,
          color: colors.textSecondary,
        ),
        prefixIcon: Icon(Icons.search, color: colors.textSecondary, size: 20),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
