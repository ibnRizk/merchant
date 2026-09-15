import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/labeled_field.dart';

/// Labeled dropdown field (e.g. store category) styled to match the other
/// profile inputs, with the chevron on the left as in the design.
class ProfileDropdownField extends StatelessWidget {
  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BrandColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            alignment: AlignmentDirectional.centerEnd,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: BrandColors.textGray,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            items: items
                .map(
                  (String item) => DropdownMenuItem<String>(
                    value: item,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: BrandColors.navy,
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
