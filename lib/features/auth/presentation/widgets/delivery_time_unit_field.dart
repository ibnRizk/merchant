import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../domain/params/register_params.dart';

/// Dropdown for the unit of the store's delivery-time range.
class DeliveryTimeUnitField extends StatelessWidget {
  const DeliveryTimeUnitField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DeliveryTimeType value;
  final ValueChanged<DeliveryTimeType> onChanged;

  static String _labelOf(DeliveryTimeType type) => switch (type) {
    DeliveryTimeType.min => Strings.unitMinutes,
    DeliveryTimeType.hours => Strings.unitHours,
    DeliveryTimeType.days => Strings.unitDays,
  };

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.border),
    );
    return LabeledField(
      label: Strings.deliveryTimeUnit,
      child: DropdownButtonFormField<DeliveryTimeType>(
        initialValue: value,
        isExpanded: true,
        onChanged: (DeliveryTimeType? type) {
          if (type != null) onChanged(type);
        },
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: colors.secondary, width: 1.5),
          ),
        ),
        items: <DropdownMenuItem<DeliveryTimeType>>[
          for (final DeliveryTimeType type in DeliveryTimeType.values)
            DropdownMenuItem<DeliveryTimeType>(
              value: type,
              child: Text(_labelOf(type)),
            ),
        ],
      ),
    );
  }
}
