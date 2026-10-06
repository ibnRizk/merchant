import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import '../../core/widgets/slider_photo.dart';
import '../../features/auth/domain/entities/merchant_auth_result.dart';
import '../../features/auth/presentation/cubit/forgot_password/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/login/login_cubit.dart';
import '../../features/auth/presentation/cubit/pending_approval/pending_approval_cubit.dart';
import '../../features/auth/presentation/cubit/register/register_cubit.dart';
import '../../features/auth/presentation/cubit/store_categories/store_categories_cubit.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/location_picker_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/pending_approval_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/home/presentation/cubit/analytics/analytics_cubit.dart';
import '../../features/home/presentation/cubit/dashboard/dashboard_cubit.dart';
import '../../features/home/presentation/cubit/store_status/store_status_cubit.dart';
import '../../features/home/presentation/pages/main_scaffold.dart';
import '../../features/hours/presentation/cubit/working_hours/working_hours_cubit.dart';
import '../../features/launch/presentation/cubit/onboarding/onboarding_cubit.dart';
import '../../features/launch/presentation/cubit/splash/splash_cubit.dart';
import '../../features/launch/presentation/pages/onboarding_screen.dart';
import '../../features/launch/presentation/pages/splash_screen.dart';
import '../../features/menu/domain/entities/product.dart';
import '../../features/menu/presentation/cubit/menu/menu_cubit.dart';
import '../../features/menu/presentation/cubit/product_form/product_form_cubit.dart';
import '../../features/menu/presentation/cubit/product_options/product_options_cubit.dart';
import '../../features/menu/presentation/pages/product_form_screen.dart';
import '../../features/menu/presentation/pages/product_options_screen.dart';
import '../../features/orders/presentation/cubit/current_orders/current_orders_cubit.dart';
import '../../features/orders/presentation/cubit/order_details/order_details_cubit.dart';
import '../../features/orders/presentation/cubit/orders_history/orders_history_cubit.dart';
import '../../features/orders/presentation/pages/active_orders_screen.dart';
import '../../features/orders/presentation/pages/order_details_screen.dart';
import '../../features/orders/presentation/pages/orders_screen.dart';
import '../../features/pharmacy/presentation/cubit/request/pharmacy_request_cubit.dart';
import '../../features/pharmacy/presentation/cubit/requests/pharmacy_requests_cubit.dart';
import '../../features/pharmacy/presentation/pages/pharmacy_request_screen.dart';
import '../../features/pharmacy/presentation/pages/pharmacy_requests_screen.dart';
import '../../features/profile/presentation/cubit/delete_account/delete_account_cubit.dart';
import '../../features/profile/presentation/cubit/logout/logout_cubit.dart';
import '../../features/profile/presentation/cubit/profile/profile_cubit.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/wallet/presentation/pages/wallet_screen.dart';
import '../../injection_container.dart';
import 'navigator_observer.dart';

abstract class AppRoutes {
  // --- Paths (for context.go / context.push) ---
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String changeLanguage = '/change-language';
  static const String photoViewer = '/photo-viewer';
  static const String newOrders = '/orders/new';
  static const String activeOrders = '/orders/active';
  static const String orderDetails = '/orders/:id';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String locationPicker = '/register/location';
  static const String pendingApproval = '/pending-approval';
  static const String productForm = '/menu/product';
  static const String productOptions = '/menu/product/options';
  static const String wallet = '/wallet';
  static const String pharmacyRequests = '/pharmacy-requests';
  static const String pharmacyRequest = '/pharmacy-requests/:id';

  // --- Names (for context.goNamed / context.pushNamed) ---
  static const String splashName = 'splash';
  static const String onboardingName = 'onboarding';
  static const String loginName = 'login';
  static const String homeName = 'home';
  static const String changeLanguageName = 'changeLanguage';
  static const String photoViewerName = 'photoViewer';
  static const String newOrdersName = 'newOrders';
  static const String activeOrdersName = 'activeOrders';
  static const String orderDetailsName = 'orderDetails';
  static const String forgotPasswordName = 'forgotPassword';
  static const String registerName = 'register';
  static const String locationPickerName = 'locationPicker';
  static const String pendingApprovalName = 'pendingApproval';
  static const String productFormName = 'productForm';
  static const String productOptionsName = 'productOptions';
  static const String walletName = 'wallet';
  static const String pharmacyRequestsName = 'pharmacyRequests';
  static const String pharmacyRequestName = 'pharmacyRequest';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    observers: <NavigatorObserver>[AppNavigatorObserver()],
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        name: splashName,
        builder: (_, __) => BlocProvider<SplashCubit>(
          create: (_) => ServiceLocator.instance<SplashCubit>()..start(),
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: onboarding,
        name: onboardingName,
        builder: (_, __) => BlocProvider<OnboardingCubit>(
          create: (_) => ServiceLocator.instance<OnboardingCubit>(),
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: login,
        name: loginName,
        builder: (_, __) => BlocProvider<LoginCubit>(
          create: (_) => ServiceLocator.instance<LoginCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: home,
        name: homeName,
        // Dashboard, order history, menu, hours and profile are tabs of
        // MainScaffold, so their cubits live at this route.
        builder: (_, __) => MultiBlocProvider(
          providers: <BlocProvider<StateStreamableSource<Object?>>>[
            BlocProvider<DashboardCubit>(
              create: (_) => ServiceLocator.instance<DashboardCubit>()..load(),
            ),
            BlocProvider<StoreStatusCubit>(
              create: (_) => ServiceLocator.instance<StoreStatusCubit>(),
            ),
            BlocProvider<AnalyticsCubit>(
              create: (_) => ServiceLocator.instance<AnalyticsCubit>()..load(),
            ),
            BlocProvider<OrdersHistoryCubit>(
              create: (_) =>
                  ServiceLocator.instance<OrdersHistoryCubit>()..load(),
            ),
            BlocProvider<MenuCubit>(
              create: (_) => ServiceLocator.instance<MenuCubit>()..load(),
            ),
            BlocProvider<ProfileCubit>(
              create: (_) =>
                  ServiceLocator.instance<ProfileCubit>()..loadProfile(),
            ),
            BlocProvider<LogoutCubit>(
              create: (_) => ServiceLocator.instance<LogoutCubit>(),
            ),
            BlocProvider<DeleteAccountCubit>(
              create: (_) => ServiceLocator.instance<DeleteAccountCubit>(),
            ),
            BlocProvider<WorkingHoursCubit>(
              create: (_) =>
                  ServiceLocator.instance<WorkingHoursCubit>()..load(),
            ),
          ],
          child: const MainScaffold(),
        ),
      ),
      // GoRoute(
      //   path: changeLanguage,
      //   name: changeLanguageName,
      //   builder: (_, __) => const ChangeLanguage(),
      // ),
      GoRoute(
        path: newOrders,
        name: newOrdersName,
        builder: (_, __) => BlocProvider<CurrentOrdersCubit>(
          create: (_) => ServiceLocator.instance<CurrentOrdersCubit>()..load(),
          child: const OrdersScreen(),
        ),
      ),
      GoRoute(
        path: activeOrders,
        name: activeOrdersName,
        builder: (_, __) => BlocProvider<CurrentOrdersCubit>(
          create: (_) => ServiceLocator.instance<CurrentOrdersCubit>()..load(),
          child: const ActiveOrdersScreen(),
        ),
      ),
      // Declared after the literal `/orders/new` and `/orders/active` paths.
      GoRoute(
        path: orderDetails,
        name: orderDetailsName,
        builder: (_, GoRouterState state) {
          final int? id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(body: Center(child: Text('Order not found')));
          }
          return BlocProvider<OrderDetailsCubit>(
            create: (_) =>
                ServiceLocator.instance<OrderDetailsCubit>()..load(id),
            child: const OrderDetailsScreen(),
          );
        },
      ),
      GoRoute(
        path: forgotPassword,
        name: forgotPasswordName,
        builder: (_, __) => BlocProvider<ForgotPasswordCubit>(
          create: (_) => ServiceLocator.instance<ForgotPasswordCubit>(),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: register,
        name: registerName,
        builder: (_, __) => MultiBlocProvider(
          providers: <BlocProvider<StateStreamableSource<Object?>>>[
            BlocProvider<RegisterCubit>(
              create: (_) => ServiceLocator.instance<RegisterCubit>(),
            ),
            BlocProvider<StoreCategoriesCubit>(
              create: (_) =>
                  ServiceLocator.instance<StoreCategoriesCubit>()..load(),
            ),
          ],
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: locationPicker,
        name: locationPickerName,
        builder: (_, GoRouterState state) =>
            LocationPickerScreen(initialLocation: state.extra as LatLng?),
      ),
      GoRoute(
        path: pendingApproval,
        name: pendingApprovalName,
        // `extra` is the status already known (login, splash or a 403), so
        // the right copy shows at once; the cubit then re-checks it.
        builder: (_, GoRouterState state) => BlocProvider<PendingApprovalCubit>(
          create: (_) =>
              ServiceLocator.instance<PendingApprovalCubit>(
                param1:
                    state.extra as MerchantApprovalStatus? ??
                    MerchantApprovalStatus.pending,
              )..check(silent: true),
          child: const PendingApprovalScreen(),
        ),
      ),
      GoRoute(
        path: productForm,
        name: productFormName,
        // `extra` is the product to edit; none means "add". Pops with the
        // saved [Product].
        builder: (_, GoRouterState state) {
          final Product? product = state.extra as Product?;
          return BlocProvider<ProductFormCubit>(
            create: (_) =>
                ServiceLocator.instance<ProductFormCubit>()
                  ..load(productId: product?.id),
            child: ProductFormScreen(initialProduct: product),
          );
        },
      ),
      GoRoute(
        path: productOptions,
        name: productOptionsName,
        // `extra` is the product whose sizes and add-ons are edited.
        builder: (_, GoRouterState state) {
          final Product product = state.extra! as Product;
          return BlocProvider<ProductOptionsCubit>(
            create: (_) =>
                ServiceLocator.instance<ProductOptionsCubit>()
                  ..load(product.id),
            child: ProductOptionsScreen(product: product),
          );
        },
      ),
      GoRoute(
        path: wallet,
        name: walletName,
        builder: (_, __) => BlocProvider<WalletCubit>(
          create: (_) => ServiceLocator.instance<WalletCubit>()..load(),
          child: const WalletScreen(),
        ),
      ),
      GoRoute(
        path: pharmacyRequests,
        name: pharmacyRequestsName,
        builder: (_, __) => BlocProvider<PharmacyRequestsCubit>(
          create: (_) =>
              ServiceLocator.instance<PharmacyRequestsCubit>()..load(),
          child: const PharmacyRequestsScreen(),
        ),
      ),
      GoRoute(
        path: pharmacyRequest,
        name: pharmacyRequestName,
        builder: (_, GoRouterState state) {
          final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return BlocProvider<PharmacyRequestCubit>(
            create: (_) =>
                ServiceLocator.instance<PharmacyRequestCubit>()..load(id),
            child: PharmacyRequestScreen(requestId: id),
          );
        },
      ),
      GoRoute(
        path: photoViewer,
        name: photoViewerName,
        builder: (_, GoRouterState state) {
          final Map<String, dynamic> args =
              (state.extra as Map<String, dynamic>?) ?? <String, dynamic>{};
          return SliderPhotoScreen(
            imagesFiles: args['imagesFiles'],
            images: args['images'],
            path: args['path'],
            imageIndex: args['imageIndex'] ?? 0,
          );
        },
      ),
    ],
    errorBuilder: (_, GoRouterState state) =>
        Scaffold(body: Center(child: Text('No route found for ${state.uri}'))),
  );

  static String get currentRoute =>
      routesStack.isEmpty ? splash : routesStack.last;

  /// The location the router is showing, e.g. `/home`.
  static String get currentPath =>
      router.routerDelegate.currentConfiguration.uri.path;

  static void pushRouteToRoutesStack(String route) => routesStack.add(route);

  static void popRouteFromRoutesStack() {
    if (routesStack.isNotEmpty) routesStack.removeLast();
  }
}
