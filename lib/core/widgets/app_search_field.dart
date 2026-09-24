import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Rounded search field shared by list screens (order history, menu
/// management, ...). Shows a clear button once there is text.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;

  /// Also called with `''` when the clear button is tapped.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      textInputAction: TextInputAction.search,
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
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, TextEditingValue value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                ),
        ),
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
