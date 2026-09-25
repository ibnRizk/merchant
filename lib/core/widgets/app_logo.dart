import 'package:flutter/material.dart';

import '../utils/values/app_assets.dart';

/// SSM brand logo. Use it wherever the brand mark appears (splash,
/// onboarding, login, ...) instead of loading [AppAssets.logo] directly.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  /// Width and height in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Decode at the displayed size instead of the full 1024px source.
    final int cacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    return Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'SSM',
    );
  }
}
