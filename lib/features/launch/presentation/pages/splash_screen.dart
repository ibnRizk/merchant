import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/entities/launch_destination.dart';
import '../cubit/splash/splash_cubit.dart';

/// First Flutter screen. Continues the native launch screen (same background
/// and logo), animates the logo in, then routes on [SplashResolved].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _logoScale = Tween<double>(
    begin: 0.85,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  late final Animation<double> _taglineOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, SplashState state) {
    if (state is! SplashResolved) return;
    context.go(switch (state.destination) {
      LaunchDestination.onboarding => AppRoutes.onboarding,
      LaunchDestination.login => AppRoutes.login,
      LaunchDestination.home => AppRoutes.home,
      LaunchDestination.pendingApproval => AppRoutes.pendingApproval,
    }, extra: state.approvalStatus);
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<SplashCubit, SplashState>(
      listener: _onStateChanged,
      child: Scaffold(
        // Matches the native launch screen color, so there is no flash.
        backgroundColor: isDark ? colors.background : colors.surface,
        body: SafeArea(
          // Full width: otherwise the column is only as wide as the logo and
          // sits at the left edge of the body.
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: <Widget>[
                const Spacer(),
                ScaleTransition(
                  scale: _logoScale,
                  child: const AppLogo(size: 180),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Text(
                    Strings.splashTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.primary,
                    ),
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
