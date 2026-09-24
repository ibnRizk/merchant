import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// One choice in an [AppDropdownField].
typedef DropdownOption<T> = ({T value, String label});

/// Dropdown styled like [AppFormField], laid out for RTL: the value and the
/// hint hug the start edge, the chevron sits at the end.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.options,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.prefixIcon,
    this.errorText,
    this.validator,
  });

  final List<DropdownOption<T>> options;

  /// Ignored when it isn't one of [options], so a stale value can't crash
  /// the dropdown.
  final T? value;
  final String hintText;
  final ValueChanged<T> onChanged;
  final IconData? prefixIcon;
  final String? errorText;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final TextStyle valueStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    );
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return DropdownButtonFormField<T>(
      initialValue: options.any((DropdownOption<T> o) => o.value == value)
          ? value
          : null,
      isExpanded: true,
      alignment: AlignmentDirectional.centerStart,
      borderRadius: BorderRadius.circular(14),
      dropdownColor: colors.surface,
      menuMaxHeight: 360,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colors.textSecondary,
      ),
      style: valueStyle,
      validator: validator,
      hint: Text(
        hintText,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: colors.textSecondary,
        ),
      ),
      decoration: InputDecoration(
        errorText: errorText,
        errorStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: colors.error,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: colors.primary),
        filled: true,
        fillColor: colors.surface,
        contentPadding: EdgeInsetsDirectional.fromSTEB(
          prefixIcon == null ? 16 : 0,
          16,
          12,
          16,
        ),
        border: border(colors.border),
        enabledBorder: border(colors.border),
        focusedBorder: border(colors.secondary, 1.5),
        errorBorder: border(colors.error),
        focusedErrorBorder: border(colors.error, 1.5),
      ),
      items: <DropdownMenuItem<T>>[
        for (final DropdownOption<T> option in options)
          DropdownMenuItem<T>(
            value: option.value,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              option.label,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ),
      ],
      onChanged: (T? selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
