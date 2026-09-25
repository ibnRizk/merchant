import 'package:flutter/material.dart';

import '../../../../core/utils/bidi_text.dart';
import '../../../../core/utils/values/app_colors.dart';

/// Greeting + store name at the start, a navy initial avatar at the end.
/// The name ellipsizes and keeps its own direction (e.g. an English store
/// name in the Arabic layout).
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.storeName,
  });

  final String greeting;

  /// Empty while the profile is loading.
  final String storeName;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String name = storeName.trim();
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name.isEmpty ? '…' : name.bidiIsolated,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: name.isEmpty
              ? Icon(Icons.storefront_rounded, color: scheme.onSecondary)
              : Text(
                  // First character, not code unit: safe for any script.
                  String.fromCharCode(name.runes.first).toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSecondary,
                  ),
                ),
        ),
      ],
    );
  }
}
