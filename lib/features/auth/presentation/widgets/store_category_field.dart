import 'package:flutter/material.dart';

import '../../../../core/entities/store_category.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/field_notice.dart';
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
    final String languageCode = Localizations.localeOf(context).languageCode;
    return LabeledField(
      label: Strings.categoryLabel,
      child: switch (state) {
        StoreCategoriesLoaded(:final categories) when categories.isNotEmpty =>
          AppDropdownField<int>(
            options: <DropdownOption<int>>[
              for (final StoreCategory category in categories)
                (
                  value: category.id,
                  label: category.localizedName(languageCode),
                ),
            ],
            value: selectedId,
            hintText: Strings.selectCategory,
            prefixIcon: Icons.category_outlined,
            errorText: errorText,
            onChanged: onChanged,
          ),
        StoreCategoriesLoaded() => FieldNotice(
          icon: Icons.info_outline_rounded,
          iconColor: colors.info,
          text: Strings.noCategoriesAvailable,
        ),
        StoreCategoriesLoading() => FieldNotice(
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
        StoreCategoriesFailure(:final message) => FieldNotice(
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
