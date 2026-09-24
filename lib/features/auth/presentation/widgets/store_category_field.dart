import 'package:flutter/material.dart';

import '../../../../core/entities/store_category.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../cubit/store_categories/store_categories_state.dart';

/// Store category picker for registration. Covers every state of the list:
/// loading, failed (with retry), empty (nothing to pick) and loaded.
class StoreCategoryField extends StatelessWidget {
  const StoreCategoryField({
    super.key,
    required this.state,
    required this.selectedId,
    required this.onChanged,
    required this.onRetry,
    this.errorText,
  });

  final StoreCategoriesState state;
  final int? selectedId;
  final ValueChanged<int> onChanged;
  final VoidCallback onRetry;

  /// Shown after a submit attempt without a category.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return LabeledField(
      label: Strings.categoryLabel,
      child: switch (state) {
        StoreCategoriesLoaded(:final categories) when categories.isNotEmpty =>
          _CategoryDropdown(
            categories: categories,
            selectedId: selectedId,
            errorText: errorText,
            onChanged: onChanged,
          ),
        StoreCategoriesLoaded() => _FieldShell(
          icon: Icons.info_outline_rounded,
          iconColor: colors.info,
          text: Strings.noCategoriesAvailable,
        ),
        StoreCategoriesLoading() => _FieldShell(
          icon: Icons.category_outlined,
          iconColor: colors.textSecondary,
          text: Strings.selectCategory,
          errorText: errorText,
          trailing: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        ),
        StoreCategoriesFailure(:final message) => _FieldShell(
          icon: Icons.error_outline_rounded,
          iconColor: colors.error,
          text: message,
          errorText: errorText,
          trailing: TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              Strings.retry,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      },
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selectedId,
    required this.errorText,
    required this.onChanged,
  });

  final List<StoreCategory> categories;
  final int? selectedId;
  final String? errorText;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String languageCode = Localizations.localeOf(context).languageCode;
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

    return DropdownButtonFormField<int>(
      // The selection is owned by the screen; a stale id must not survive a
      // reload that no longer contains it.
      initialValue: categories.any((StoreCategory c) => c.id == selectedId)
          ? selectedId
          : null,
      isExpanded: true,
      // Start-aligned, so the value hugs the right edge in Arabic.
      alignment: AlignmentDirectional.centerStart,
      borderRadius: BorderRadius.circular(14),
      dropdownColor: colors.surface,
      menuMaxHeight: 360,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colors.textSecondary,
      ),
      style: valueStyle,
      hint: Text(
        Strings.selectCategory,
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
        prefixIcon: Icon(Icons.category_outlined, color: colors.primary),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 16, 12, 16),
        border: border(colors.border),
        enabledBorder: border(colors.border),
        focusedBorder: border(colors.secondary, 1.5),
        errorBorder: border(colors.error),
        focusedErrorBorder: border(colors.error, 1.5),
      ),
      items: <DropdownMenuItem<int>>[
        for (final StoreCategory category in categories)
          DropdownMenuItem<int>(
            value: category.id,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              category.localizedName(languageCode),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          ),
      ],
      onChanged: (int? id) {
        if (id != null) onChanged(id);
      },
    );
  }
}

/// Field-shaped placeholder for the states where there's nothing to pick.
class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.trailing,
    this.errorText,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Widget? trailing;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 8, 8),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText == null ? colors.border : colors.error,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 8),
                trailing!,
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
            child: Text(
              errorText!,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: colors.error,
              ),
            ),
          ),
      ],
    );
  }
}
