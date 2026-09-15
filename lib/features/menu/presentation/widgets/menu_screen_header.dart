import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import 'add_product_button.dart';

/// "إدارة المنيو" title with the "+ منتج" add button on the left.
class MenuScreenHeader extends StatelessWidget {
  const MenuScreenHeader({
    super.key,
    required this.title,
    required this.addLabel,
    required this.onAddTap,
  });

  final String title;
  final String addLabel;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: BrandColors.navy,
          ),
        ),
        AddProductButton(label: addLabel, onTap: onAddTap),
      ],
    );
  }
}
