import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';

/// Navy avatar + greeting/store-name pair shown at the top of the dashboard.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greeting,
    required this.storeName,
    required this.avatarLetter,
  });

  final String greeting;
  final String storeName;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BrandColors.navy,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            avatarLetter,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                greeting,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: BrandColors.textGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                storeName,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: BrandColors.navy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
