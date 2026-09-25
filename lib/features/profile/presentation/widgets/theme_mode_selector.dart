import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/enums.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';

/// Light / Dark / System segmented control with a sliding thumb.
///
/// The thumb is positioned with [AlignmentDirectional], so the segment order
/// follows the reading direction: Light sits on the right in Arabic and on
/// the left in English.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Themes selected;
  final ValueChanged<Themes> onChanged;

  static const Duration _duration = Duration(milliseconds: 320);
  static const Curve _curve = Curves.easeOutCubic;
  static const List<Themes> _order = <Themes>[
    Themes.light,
    Themes.dark,
    Themes.system,
  ];

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final int index = _order.indexOf(selected);
    // -1 = start edge, 1 = end edge.
    final double thumbX = -1 + index * 2 / (_order.length - 1);

    return Container(
      height: 72,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedAlign(
            alignment: AlignmentDirectional(thumbX, 0),
            duration: _duration,
            curve: _curve,
            child: FractionallySizedBox(
              widthFactor: 1 / _order.length,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              for (final Themes theme in _order)
                Expanded(
                  child: _Segment(
                    icon: _iconOf(theme),
                    label: _labelOf(theme),
                    isSelected: theme == selected,
                    onTap: () => onChanged(theme),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _iconOf(Themes theme) => switch (theme) {
    Themes.light => Icons.light_mode_rounded,
    Themes.dark => Icons.dark_mode_rounded,
    Themes.system => Icons.brightness_auto_rounded,
  };

  static String _labelOf(Themes theme) => switch (theme) {
    Themes.light => Strings.lightMode,
    Themes.dark => Strings.darkMode,
    Themes.system => Strings.systemMode,
  };
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : context.colors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isSelected) return;
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedScale(
              scale: isSelected ? 1.12 : 1,
              duration: ThemeModeSelector._duration,
              curve: ThemeModeSelector._curve,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: foreground),
                duration: ThemeModeSelector._duration,
                builder: (_, Color? color, __) =>
                    Icon(icon, size: 21, color: color),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: ThemeModeSelector._duration,
              curve: ThemeModeSelector._curve,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                height: 1.2,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: foreground,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
