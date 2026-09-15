import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Tappable square placeholder for the product photo. Empty [onTap] is
/// ready to launch an image picker.
class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: BrandColors.fieldFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 132,
            height: 132,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BrandColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.add_a_photo_outlined,
                  size: 28,
                  color: BrandColors.textGray,
                ),
                const SizedBox(height: 8),
                Text(
                  'إضافة صورة المنتج',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
