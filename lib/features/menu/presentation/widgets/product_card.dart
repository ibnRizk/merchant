import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/status_pill.dart';

class ProductEntry {
  const ProductEntry({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.isAvailable,
    required this.statusLabel,
    this.addOns = const <String>[],
  });

  final String name;
  final String subtitle;
  final String price;
  final bool isAvailable;
  final String statusLabel;
  final List<String> addOns;
}

/// One row in the menu list: name/add-ons/edit link on the right, price +
/// availability pill in the middle, a kebab menu on the far left.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onMoreTap,
  });

  final ProductEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: Text(
                    Strings.editProduct,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                entry.price,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              StatusPill(
                label: entry.statusLabel,
                background: entry.isAvailable
                    ? colors.successContainer
                    : colors.background,
                textColor: entry.isAvailable
                    ? colors.success
                    : colors.textSecondary,
              ),
            ],
          ),
          SizedBox(
            width: 28,
            child: IconButton(
              onPressed: onMoreTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
