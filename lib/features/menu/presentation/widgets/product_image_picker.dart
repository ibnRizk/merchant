import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Tappable square placeholder for the product photo. Empty [onTap] is
/// ready to launch an image picker.
class ProductImagePicker extends StatelessWidget {
  const ProductImagePicker({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Center(
      child: Material(
        color: colors.background,
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
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.add_a_photo_outlined,
                  size: 28,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  'إضافة صورة المنتج',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
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
