import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/env/app_env.dart';
import 'config/locale/app_localizations_setup.dart';
import 'config/locale/locale_cubit.dart';
import 'config/routes/app_routes.dart';
import 'config/routes/push_tap_router.dart';
import 'config/themes/app_theme.dart';
import 'config/themes/theme_cubit.dart';
import 'core/entities/merchant_approval_status.dart';
import 'core/utils/enums.dart';
import 'core/utils/values/app_colors.dart';
import 'features/app_config/presentation/cubit/app_config_cubit.dart';
import 'injection_container.dart';

/// Set this to your Figma frame size. Every `.w/.h/.sp/.r` is relative to it.
const Size kDesignSize = Size(390, 844);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<void>? _unauthorizedSub;
  StreamSubscription<MerchantApprovalStatus>? _restrictedSub;

  @override
  void initState() {
    super.initState();
    // Notification taps, including the one that launched the app.
    ServiceLocator.instance<PushTapRouter>().attach();
    // Any 401 from a token-protected request lands here. Clear the session
    // and bounce back to login.
    _unauthorizedSub = eventBus.unauthorizedStream.listen((_) async {
      await secureStorage.clearAll();
      AppRoutes.router.go(AppRoutes.login);
    });
    // A 403 `merchant-not-approved` / `merchant-suspended`. The token stays:
    // the pending screen still needs it to check the status again.
    _restrictedSub = eventBus.accountRestrictedStream.listen((
      MerchantApprovalStatus status,
    ) {
      // The home screen fires several requests at once; route only once.
      if (AppRoutes.currentPath == AppRoutes.pendingApproval) return;
      AppRoutes.router.go(AppRoutes.pendingApproval, extra: status);
    });
  }

  @override
  void dispose() {
    _unauthorizedSub?.cancel();
    _restrictedSub?.cancel();
    ServiceLocator.instance<PushTapRouter>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<StateStreamableSource<Object?>>>[
        BlocProvider<ThemeCubit>(
          create: (_) => ServiceLocator.instance<ThemeCubit>(),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => ServiceLocator.instance<LocaleCubit>(),
        ),
        BlocProvider<AppConfigCubit>(
          create: (_) => ServiceLocator.instance<AppConfigCubit>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: kDesignSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) {
          return BlocBuilder<ThemeCubit, Themes>(
            builder: (_, Themes theme) {
              return BlocBuilder<LocaleCubit, LanguageCode>(
                builder: (_, LanguageCode languageCode) {
                  return MaterialApp.router(
                    title: AppEnv.appName,
                    debugShowCheckedModeBanner: false,
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: switch (theme) {
                      Themes.light => ThemeMode.light,
                      Themes.dark => ThemeMode.dark,
                      Themes.system => ThemeMode.system,
                    },
                    // Explicit locale (rather than following the device)
                    // so LocaleCubit's toggle is the single source of
                    // truth; Directionality follows it automatically.
                    locale: Locale(languageCode.name),
                    supportedLocales: AppLocalizationsSetup.supportedLocales,
                    localizationsDelegates:
                        AppLocalizationsSetup.localizationsDelegates,
                    localeResolutionCallback:
                        AppLocalizationsSetup.localeResolutionCallback,
                    routerConfig: AppRoutes.router,
                    builder: (BuildContext ctx, Widget? child) {
                      // Keeps the context-free `colors` getter in sync with
                      // the active theme, replacing the side effect the
                      // source had inside AppColors.lerp().
                      ServiceLocator.injectAppColors(
                        Theme.of(ctx).extension<AppColors>()!,
                      );
                      return child ?? const SizedBox.shrink();
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
