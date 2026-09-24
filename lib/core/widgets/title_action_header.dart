import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Screen title with a small primary-colored pill action button (e.g.
/// "حفظ"). Shared by the working-hours and profile screens.
class TitleActionHeader extends StatelessWidget {
  const TitleActionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
    this.isLoading = false,
  });

  final String title;
  final String actionLabel;

  /// `null` renders the pill disabled.
  final VoidCallback? onActionTap;

  /// Swaps the label for a spinner and ignores taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isEnabled = onActionTap != null && !isLoading;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        Material(
          color: isEnabled || isLoading
              ? colors.primary
              : colors.primary.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: isEnabled ? onActionTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isLoading
                    ? SizedBox.square(
                        key: const ValueKey<bool>(true),
                        dimension: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Text(
                        actionLabel,
                        key: const ValueKey<bool>(false),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
