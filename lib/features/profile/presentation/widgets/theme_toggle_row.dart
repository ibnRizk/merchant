import 'package:flutter/material.dart';

import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// "Appearance / المظهر" segmented switcher, driving [ThemeCubit]. Mirrors
/// [LanguageToggleRow]'s layout with a third (System) segment.
class ThemeToggleRow extends StatelessWidget {
  const ThemeToggleRow({super.key, required this.theme, required this.onChanged});

  final Themes theme;
  final ValueChanged<Themes> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              Strings.theme,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _Segment(
                  label: Strings.lightMode,
                  isSelected: theme == Themes.light,
                  onTap: () => onChanged(Themes.light),
                ),
                _Segment(
                  label: Strings.darkMode,
                  isSelected: theme == Themes.dark,
                  onTap: () => onChanged(Themes.dark),
                ),
                _Segment(
                  label: Strings.systemMode,
                  isSelected: theme == Themes.system,
                  onTap: () => onChanged(Themes.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppColors colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? scheme.onPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
