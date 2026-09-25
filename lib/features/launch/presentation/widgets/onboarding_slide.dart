import 'package:flutter/material.dart';

import '../../../../core/utils/values/strings.dart';

/// Content of one onboarding page.
class OnboardingSlide {
  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Built on demand so the text follows the current locale.
  static List<OnboardingSlide> all() => <OnboardingSlide>[
    OnboardingSlide(
      icon: Icons.notifications_active_rounded,
      title: Strings.onboardingOrdersTitle,
      body: Strings.onboardingOrdersBody,
    ),
    OnboardingSlide(
      icon: Icons.restaurant_menu_rounded,
      title: Strings.onboardingMenuTitle,
      body: Strings.onboardingMenuBody,
    ),
    OnboardingSlide(
      icon: Icons.storefront_rounded,
      title: Strings.onboardingStoreTitle,
      body: Strings.onboardingStoreBody,
    ),
  ];
}
