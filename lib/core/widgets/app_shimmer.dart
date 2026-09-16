import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/values/app_colors.dart';

class AppShimmer extends StatefulWidget {
  final Widget child;

  const AppShimmer({required this.child, super.key});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> {
  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.border,
      highlightColor: colors.background,
      child: widget.child,
    );
  }
}
