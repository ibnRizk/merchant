import 'package:flutter/material.dart';

import '../utils/values/app_colors.dart';
import 'brand_back_button.dart';

/// Back button and title for a pushed screen, with an optional [trailing]
/// action at the end.
class BackTitleBar extends StatelessWidget {
  const BackTitleBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const BrandBackButton(),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 10), trailing!],
      ],
    );
  }
}
