import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';

/// Rounded, bordered surface container used to group a screen's sections.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: child,
    );
  }
}

/// A [SurfaceCard] section title.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: context.colors.textPrimary,
      ),
    );
  }
}
