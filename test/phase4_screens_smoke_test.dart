import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssm_merchant/config/locale/locale_cubit.dart';
import 'package:ssm_merchant/config/themes/app_theme.dart';
import 'package:ssm_merchant/core/error/failures.dart';
import 'package:ssm_merchant/core/services/local_storage/app_shared_preferences.dart';
import 'package:ssm_merchant/core/utils/values/strings.dart';
import 'package:ssm_merchant/features/app_config/domain/entities/app_config.dart';
import 'package:ssm_merchant/features/app_config/domain/repos/app_config_repository.dart';
import 'package:ssm_merchant/features/app_config/presentation/cubit/app_config_cubit.dart';
import 'package:ssm_merchant/features/home/domain/entities/store_analytics.dart';
import 'package:ssm_merchant/features/home/domain/repos/analytics_repository.dart';
import 'package:ssm_merchant/features/home/presentation/cubit/analytics/analytics_cubit.dart';
import 'package:ssm_merchant/features/home/presentation/widgets/analytics_section.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product.dart';
import 'package:ssm_merchant/features/menu/domain/entities/product_options.dart';
import 'package:ssm_merchant/features/menu/presentation/cubit/product_options/product_options_cubit.dart';
import 'package:ssm_merchant/features/menu/presentation/pages/product_options_screen.dart';
import 'package:ssm_merchant/features/pharmacy/domain/entities/pharmacy_request.dart';
import 'package:ssm_merchant/features/pharmacy/presentation/cubit/request/pharmacy_request_cubit.dart';
import 'package:ssm_merchant/features/pharmacy/presentation/cubit/requests/pharmacy_requests_cubit.dart';
import 'package:ssm_merchant/features/pharmacy/presentation/pages/pharmacy_request_screen.dart';
import 'package:ssm_merchant/features/pharmacy/presentation/pages/pharmacy_requests_screen.dart';
import 'package:ssm_merchant/features/wallet/domain/entities/wallet.dart';
import 'package:ssm_merchant/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:ssm_merchant/features/wallet/presentation/pages/wallet_screen.dart';
import 'package:ssm_merchant/injection_container.dart';

import 'features/menu/menu_fakes.dart';
import 'features/pharmacy/pharmacy_fakes.dart';
import 'features/wallet/wallet_fakes.dart';
import 'helpers/test_localizations.dart';

/// Renders each Phase 4 screen at phone width with realistic data and
/// fails on any layout or build exception.
class _ConfigRepository implements AppConfigRepository {
  @override
  AppConfig cachedConfig() => AppConfig.empty;

  @override
  Future<Either<Failure, AppConfig>> fetchConfig() async =>
      const Right(AppConfig.empty);
}

class _AnalyticsRepository implements AnalyticsRepository {
  @override
  Future<Either<Failure, StoreAnalytics>> getAnalytics({
    required DateTime from,
    required DateTime to,
  }) async => const Right(
    StoreAnalytics(
      totalOrders: 40,
      deliveredOrders: 31,
      cancelledOrders: 4,
      totalSales: 12850.75,
      averageOrderValue: 321.27,
      topItems: <TopItem>[
        TopItem(name: 'Chicken shawarma sandwich, large', quantity: 120),
        TopItem(name: 'Fries', quantity: 64),
        TopItem(name: 'Water', quantity: 0),
      ],
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen,
  List<BlocProvider> providers,
) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
          BlocProvider<AppConfigCubit>(
            create: (_) => AppConfigCubit(repository: _ConfigRepository()),
          ),
          ...providers,
        ],
        child: MaterialApp(
          theme: lightTheme,
          home: Directionality(
            textDirection: appLocalizations.isArLocale
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: screen,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ServiceLocator.instance.registerLazySingleton<AppSharedPreferences>(
      () => AppSharedPreferencesImpl(instance: prefs),
    );
    await registerTestLocalizations();
    await initializeDateFormatting();
  });

  for (final String language in <String>['en', 'ar']) {
    group(language, () {
      setUp(() async {
        if (language == 'ar') {
          await appLocalizations.load(locale: const Locale('ar'));
        } else {
          await appLocalizations.load(locale: const Locale('en'));
        }
      });

      testWidgets('wallet screen and payout sheet', (
        WidgetTester tester,
      ) async {
        final FakeWalletRepository repository = FakeWalletRepository()
          ..walletResult = Right(
            WalletOverview(
              balance: balanceOf(1250.5),
              withdrawals: <WithdrawRequest>[
                WithdrawRequest(
                  id: 1,
                  amount: 500,
                  status: WithdrawStatus.pending,
                  createdAt: DateTime(2026, 3, 2),
                ),
                const WithdrawRequest(
                  id: 2,
                  amount: 99.99,
                  status: WithdrawStatus.denied,
                ),
              ],
            ),
          );
        await _pump(tester, const WalletScreen(), <BlocProvider>[
          BlocProvider<WalletCubit>(
            create: (_) => WalletCubit(repository: repository)..load(),
          ),
        ]);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text(Strings.requestPayout));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '99999');
        await tester.tap(find.text(Strings.submitPayout));
        await tester.pumpAndSettle();

        expect(find.text(Strings.withdrawAmountAboveBalance), findsOneWidget);
        expect(repository.withdrawals, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('analytics section', (WidgetTester tester) async {
        await _pump(
          tester,
          const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: AnalyticsSection(),
            ),
          ),
          <BlocProvider>[
            BlocProvider<AnalyticsCubit>(
              create: (_) =>
                  AnalyticsCubit(repository: _AnalyticsRepository())..load(),
            ),
          ],
        );
        expect(find.text(Strings.topItems), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('product options editor', (WidgetTester tester) async {
        const Product pizza = Product(
          id: 4,
          name: 'Pizza',
          description: '',
          price: 20,
          isActive: true,
          options: ProductOptions(
            variationTitle: 'Size',
            variations: <ProductVariation>[
              ProductVariation(name: 'Small', price: 20),
              ProductVariation(name: 'Large', price: 32.5),
            ],
            addOns: <ProductAddOn>[ProductAddOn(name: 'Cheese', price: 5)],
          ),
        );
        final FakeCatalogRepository repository = FakeCatalogRepository()
          ..productResult = const Right(pizza);
        await _pump(
          tester,
          const ProductOptionsScreen(product: pizza),
          <BlocProvider>[
            BlocProvider<ProductOptionsCubit>(
              create: (_) =>
                  ProductOptionsCubit(repository: repository)..load(4),
            ),
          ],
        );
        expect(find.text('Large'), findsOneWidget);

        await tester.tap(find.text(Strings.addAddOn));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(Strings.saveOptions));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Strings.saveOptions));
        await tester.pumpAndSettle();

        // The new, empty add-on row blocks the save.
        expect(find.text(Strings.optionNameRequired), findsOneWidget);
        expect(repository.optionUpdates, isEmpty);
        expect(tester.takeException(), isNull);
      });

      testWidgets('pharmacy requests and quote', (WidgetTester tester) async {
        final FakePharmacyRepository repository = FakePharmacyRepository()
          ..requestResult = Right(
            PharmacyRequest(
              id: 7,
              status: PharmacyRequestStatus.submitted,
              customerName: 'Sara Ali',
              customerNote: 'Panadol Extra x2, Vitamin C',
              hasPrescription: true,
              createdAt: DateTime(2026, 3, 2, 14, 20),
            ),
          )
          ..prescriptionResult = Right(Uint8List.fromList(<int>[1, 2, 3]));

        await _pump(tester, const PharmacyRequestsScreen(), <BlocProvider>[
          BlocProvider<PharmacyRequestsCubit>(
            create: (_) =>
                PharmacyRequestsCubit(repository: repository)..load(),
          ),
        ]);
        expect(tester.takeException(), isNull);

        await _pump(
          tester,
          const PharmacyRequestScreen(requestId: 7),
          <BlocProvider>[
            BlocProvider<PharmacyRequestCubit>(
              create: (_) =>
                  PharmacyRequestCubit(repository: repository)..load(7),
            ),
          ],
        );
        await tester.enterText(find.byType(TextFormField).at(0), '185.5');
        await tester.enterText(find.byType(TextFormField).at(1), 'Panadol');
        await tester.ensureVisible(find.text(Strings.sendQuote));
        await tester.pumpAndSettle();
        await tester.tap(find.text(Strings.sendQuote));
        await tester.pumpAndSettle();

        expect(repository.quotes.single.amount, 185.5);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
