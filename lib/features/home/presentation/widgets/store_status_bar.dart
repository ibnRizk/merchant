import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_toggle.dart';

/// Green "store open/closed" bar with the [BrandToggle] switch.
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
        color: context.colors.successContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              isOpen ? Strings.storeOpen : Strings.storeClosed,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: context.colors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),
          BrandToggle(value: isOpen, onChanged: onChanged),
        ],
      ),
    );
  }
}
