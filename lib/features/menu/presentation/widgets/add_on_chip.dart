import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// One removable add-on tag (e.g. "جبنة") inside [AddOnsInput].
class AddOnChip extends StatelessWidget {
  const AddOnChip({super.key, required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 12, left: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: BrandColors.peachBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: BrandColors.orange,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.close, size: 16, color: BrandColors.orange),
          ),
        ],
      ),
    );
  }
}
