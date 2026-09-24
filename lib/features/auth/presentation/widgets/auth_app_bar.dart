import 'package:flutter/material.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/widgets/brand_back_button.dart';

/// Flat app bar with the brand back button, shared by the pushed auth screens.
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: const Padding(
        padding: EdgeInsetsDirectional.only(start: 16),
        child: BrandBackButton(),
      ),
    );
  }
}
