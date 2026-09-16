import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Orange "+ منتج" pill button that opens the add-product flow.
class AddProductButton extends StatelessWidget {
  const AddProductButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.add, size: 16, color: scheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
