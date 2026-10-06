import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Options sheet opened from a [ProductCard]'s kebab menu.
class ProductOptionsSheet extends StatelessWidget {
  const ProductOptionsSheet({
    super.key,
    required this.productName,
    required this.onEdit,
    required this.onEditOptions,
    required this.onDelete,
  });

  final String productName;
  final VoidCallback onEdit;

  /// Sizes and add-ons.
  final VoidCallback onEditOptions;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.edit_outlined,
              label: Strings.editProduct,
              color: colors.textPrimary,
              onTap: onEdit,
            ),
            _OptionTile(
              icon: Icons.tune_rounded,
              label: Strings.sizesAndAddOns,
              color: colors.textPrimary,
              onTap: onEditOptions,
            ),
            _OptionTile(
              icon: Icons.delete_outline,
              label: Strings.deleteProduct,
              color: colors.error,
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
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
