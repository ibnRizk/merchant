import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_toggle.dart';

/// "Store open/closed" bar with the [BrandToggle] switch: green while open,
/// neutral while closed. The switch is dimmed with a spinner over it while a
/// change is in flight, and hidden until the status is known.
class StoreStatusBar extends StatelessWidget {
  const StoreStatusBar({
    super.key,
    required this.isOpen,
    required this.isUpdating,
    required this.onChanged,
  });

  /// `null` while the status is still loading.
  final bool? isOpen;
  final bool isUpdating;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool open = isOpen ?? false;
    final Color foreground = open ? colors.success : colors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: open ? colors.successContainer : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: open ? null : Border.all(color: colors.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            open
                ? Icons.storefront_rounded
                : Icons.store_mall_directory_outlined,
            size: 20,
            color: foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOpen == null
                  ? Strings.loading
                  : (open ? Strings.storeOpen : Strings.storeClosed),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (isOpen != null) _buildSwitch(colors, open),
        ],
      ),
    );
  }

  Widget _buildSwitch(AppColors colors, bool open) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AbsorbPointer(
          absorbing: isUpdating,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isUpdating ? 0.5 : 1,
            child: BrandToggle(value: open, onChanged: onChanged),
          ),
        ),
        if (isUpdating)
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
      ],
    );
  }
}
