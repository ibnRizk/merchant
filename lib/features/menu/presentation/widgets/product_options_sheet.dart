import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Options sheet opened from a [ProductCard]'s kebab menu.
class ProductOptionsSheet extends StatelessWidget {
  const ProductOptionsSheet({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'تعديل المنتج',
              color: BrandColors.navy,
              onTap: onEdit,
            ),
            const SizedBox(height: 4),
            _OptionTile(
              icon: Icons.delete_outline,
              label: 'حذف المنتج',
              color: BrandColors.cancelledText,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
