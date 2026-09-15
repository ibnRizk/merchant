import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

class NavItemData {
  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// 5-item bottom navigation bar used by [MainScaffold]. RTL-aware: item
/// order in [items] flows right-to-left under an RTL [Directionality].
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<NavItemData> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEFF1F4))),
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (int index) {
            final NavItemData item = items[index];
            final bool isSelected = index == selectedIndex;
            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 22,
                      color: isSelected
                          ? BrandColors.orange
                          : BrandColors.textGray,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected
                            ? BrandColors.orange
                            : BrandColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
