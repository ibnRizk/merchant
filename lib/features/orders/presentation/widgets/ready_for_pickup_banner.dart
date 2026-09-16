import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';

/// Navy info banner explaining what happens after the merchant marks an
/// order ready — the quoted phrase is highlighted in brand orange.
class ReadyForPickupBanner extends StatelessWidget {
  const ReadyForPickupBanner({
    super.key,
    required this.prefix,
    required this.highlighted,
    required this.subtitle,
  });

  final String prefix;
  final String highlighted;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.onSecondary,
              ),
              children: <InlineSpan>[
                TextSpan(text: prefix),
                TextSpan(
                  text: highlighted,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
              color: scheme.onSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
