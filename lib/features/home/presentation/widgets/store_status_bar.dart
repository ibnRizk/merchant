import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import 'store_toggle.dart';

/// Green "store open/closed" bar with the [StoreToggle] switch.
class StoreStatusBar extends StatelessWidget {
  const StoreStatusBar({
    super.key,
    required this.isOpen,
    required this.onChanged,
  });

  final bool isOpen;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: BrandColors.statusBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          StoreToggle(value: isOpen, onChanged: onChanged),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'المتجر مفتوح لاستقبال الطلبات',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: BrandColors.statusText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
