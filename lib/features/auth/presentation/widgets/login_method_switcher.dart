import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

enum LoginMethod { username, phone }

/// Segmented "اسم المستخدم / رقم الجوال" tab switcher.
class LoginMethodSwitcher extends StatelessWidget {
  const LoginMethodSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final LoginMethod selected;
  final ValueChanged<LoginMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrandColors.fieldFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          _Tab(
            label: 'اسم المستخدم',
            isSelected: selected == LoginMethod.username,
            onTap: () => onChanged(LoginMethod.username),
          ),
          _Tab(
            label: 'رقم الجوال',
            isSelected: selected == LoginMethod.phone,
            onTap: () => onChanged(LoginMethod.phone),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? BrandColors.orange.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? BrandColors.orange : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
