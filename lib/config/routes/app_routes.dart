import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/slider_photo.dart';
import '../../features/home/presentation/pages/main_scaffold.dart';
import '../../features/orders/presentation/pages/active_orders_screen.dart';
import '../../features/orders/presentation/pages/orders_screen.dart';
import '../../injection_container.dart';
import 'navigator_observer.dart';

abstract class AppRoutes {
  // --- Paths (for context.go / context.push) ---
  static const String splash = '/';
  static const String home = '/home';
  static const String changeLanguage = '/change-language';
  static const String photoViewer = '/photo-viewer';
  static const String newOrders = '/orders/new';
  static const String activeOrders = '/orders/active';

  // --- Names (for context.goNamed / context.pushNamed) ---
  static const String splashName = 'splash';
  static const String homeName = 'home';
  static const String changeLanguageName = 'changeLanguage';
  static const String photoViewerName = 'photoViewer';
  static const String newOrdersName = 'newOrders';
  static const String activeOrdersName = 'activeOrders';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    observers: <NavigatorObserver>[AppNavigatorObserver()],
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // GoRoute(
      //   path: splash,
      //   name: splashName,
      //   builder: (_, __) => const SplashScreen(),
      // ),
      GoRoute(
        path: home,
        name: homeName,
        builder: (_, __) => const MainScaffold(),
      ),
      // GoRoute(
      //   path: changeLanguage,
      //   name: changeLanguageName,
      //   builder: (_, __) => const ChangeLanguage(),
      // ),
      GoRoute(
        path: newOrders,
        name: newOrdersName,
        builder: (_, __) => const OrdersScreen(),
      ),
      GoRoute(
        path: activeOrders,
        name: activeOrdersName,
        builder: (_, __) => const ActiveOrdersScreen(),
      ),
      GoRoute(
        path: photoViewer,
        name: photoViewerName,
        builder: (_, GoRouterState state) {
          final Map<String, dynamic> args =
              (state.extra as Map<String, dynamic>?) ??
              <String, dynamic>{};
          return SliderPhotoScreen(
            imagesFiles: args['imagesFiles'],
            images: args['images'],
            path: args['path'],
            imageIndex: args['imageIndex'] ?? 0,
          );
        },
      ),
    ],
    errorBuilder: (_, GoRouterState state) => Scaffold(
      body: Center(
        child: Text('No route found for ${state.uri}'),
      ),
    ),
  );

  static String get currentRoute =>
      routesStack.isEmpty ? splash : routesStack.last;

  static void pushRouteToRoutesStack(String route) =>
      routesStack.add(route);

  static void popRouteFromRoutesStack() {
    if (routesStack.isNotEmpty) routesStack.removeLast();
  }
}
