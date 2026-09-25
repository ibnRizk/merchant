import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/onboarding/onboarding_cubit.dart';
import '../widgets/onboarding_page_indicator.dart';
import '../widgets/onboarding_slide.dart';
import '../widgets/onboarding_slide_view.dart';

/// First-launch introduction. Finishing or skipping it goes to login.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  /// Current page. A notifier so only the indicator and buttons rebuild on
  /// swipe, not the whole page view.
  final ValueNotifier<int> _page = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _page.dispose();
    super.dispose();
  }

  void _onNext(int slideCount) {
    if (_page.value >= slideCount - 1) {
      context.read<OnboardingCubit>().complete();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final List<OnboardingSlide> slides = OnboardingSlide.all();
    final int lastIndex = slides.length - 1;
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (BuildContext context, OnboardingState state) {
        if (state is OnboardingCompleted) context.go(AppRoutes.login);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const AppLogo(size: 44),
                    const Spacer(),
                    ValueListenableBuilder<int>(
                      valueListenable: _page,
                      builder: (BuildContext context, int page, _) =>
                          Visibility(
                            visible: page < lastIndex,
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            child: TextButton(
                              onPressed: () =>
                                  context.read<OnboardingCubit>().complete(),
                              child: Text(
                                Strings.onboardingSkip,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (int index) => _page.value = index,
                    itemBuilder: (_, int index) =>
                        OnboardingSlideView(slide: slides[index]),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _page,
                  builder: (_, int page, _) => Column(
                    children: <Widget>[
                      OnboardingPageIndicator(
                        count: slides.length,
                        current: page,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          label: page == lastIndex
                              ? Strings.onboardingGetStarted
                              : Strings.onboardingNext,
                          onPressed: () => _onNext(slides.length),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
