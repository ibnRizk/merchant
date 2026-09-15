import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF1F4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  entry.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: BrandColors.textGray,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onEdit,
                  child: const Text(
                    'تعديل المنتج',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: BrandColors.orange,
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
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.orange,
                ),
              ),
              const SizedBox(height: 8),
              StatusPill(
                label: entry.statusLabel,
                background: entry.isAvailable
                    ? BrandColors.statusBg
                    : BrandColors.fieldFill,
                textColor: entry.isAvailable
                    ? BrandColors.statusText
                    : BrandColors.textGray,
              ),
            ],
          ),
          SizedBox(
            width: 28,
            child: IconButton(
              onPressed: onMoreTap,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.more_vert,
                size: 20,
                color: BrandColors.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
