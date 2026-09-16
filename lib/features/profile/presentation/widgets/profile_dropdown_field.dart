import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';

/// Labeled dropdown field (e.g. store category) styled to match the other
/// profile inputs, with the chevron on the left as in the design.
///
/// [options] maps each stable, locale-independent value to its localized
/// display label — keeping the two separate means the selected item stays
/// matched after a language switch, instead of losing its selection because
/// the display text (and therefore the old value) changed underneath it.
class ProfileDropdownField extends StatelessWidget {
  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return LabeledField(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            alignment: AlignmentDirectional.centerEnd,
            icon: Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            items: options.entries
                .map(
                  (MapEntry<String, String> entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
