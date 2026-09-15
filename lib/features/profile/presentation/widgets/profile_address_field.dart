import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/labeled_field.dart';

/// Read-only, tappable address field — not a text input. Tapping it is
/// meant to launch a map picker rather than open the keyboard.
class ProfileAddressField extends StatelessWidget {
  const ProfileAddressField({
    super.key,
    required this.label,
    required this.address,
    required this.onTap,
  });

  final String label;
  final String address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BrandColors.border),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    address,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BrandColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: BrandColors.textGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
