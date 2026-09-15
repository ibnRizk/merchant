import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/brand_toggle.dart';

/// Label + [BrandToggle] row for the product's availability status.
class AvailabilityToggleRow extends StatelessWidget {
  const AvailabilityToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BrandColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BrandColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          BrandToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
