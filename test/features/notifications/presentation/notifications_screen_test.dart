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
import 'package:ssm_merchant/core/realtime/realtime_hub.dart';
import 'package:ssm_merchant/core/services/local_storage/app_shared_preferences.dart';
import 'package:ssm_merchant/core/utils/values/strings.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/app_notification.dart';
import 'package:ssm_merchant/features/notifications/domain/entities/notifications_page.dart';
import 'package:ssm_merchant/features/notifications/presentation/cubit/notifications/notifications_cubit.dart';
import 'package:ssm_merchant/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:ssm_merchant/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:ssm_merchant/injection_container.dart';

import '../../../helpers/test_localizations.dart';
import '../notifications_fakes.dart';

Future<NotificationsCubit> _pump(
  WidgetTester tester,
  FakeNotificationsRepository repository,
) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final NotificationsCubit cubit = NotificationsCubit(repository: repository);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, __) => MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
          BlocProvider<NotificationsCubit>.value(value: cubit..load()),
        ],
        child: MaterialApp(
          theme: lightTheme,
          home: Directionality(
            textDirection: appLocalizations.isArLocale
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: const NotificationsScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    ServiceLocator.instance
      ..registerLazySingleton<AppSharedPreferences>(
        () => AppSharedPreferencesImpl(instance: prefs),
      )
      ..registerLazySingleton<RealtimeHub>(RealtimeHub.new);
    await registerTestLocalizations();
    await initializeDateFormatting();
  });

  for (final String language in <String>['en', 'ar']) {
    group(language, () {
      setUp(() => appLocalizations.load(locale: Locale(language)));

      testWidgets('lists read and unread notifications by day', (
        WidgetTester tester,
      ) async {
        final DateTime now = DateTime.now();
        final FakeNotificationsRepository repository =
            FakeNotificationsRepository()
              ..pages[1] = Right<Failure, NotificationsPage>(
                NotificationsPage(
                  items: <AppNotification>[
                    notification('a', orderId: 120, createdAt: now),
                    notification(
                      'b',
                      isRead: true,
                      createdAt: now.subtract(const Duration(days: 3)),
                    ),
                  ],
                  hasMore: false,
                ),
              );

        await _pump(tester, repository);

        expect(find.byType(NotificationTile), findsNWidgets(2));
        expect(find.text(Strings.today), findsOneWidget);
        expect(find.text(Strings.notificationsEarlier), findsOneWidget);
        expect(find.text(Strings.notificationViewOrder), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('mark all as read clears the unread state', (
        WidgetTester tester,
      ) async {
        final FakeNotificationsRepository repository =
            FakeNotificationsRepository()
              ..pages[1] = Right<Failure, NotificationsPage>(
                NotificationsPage(
                  items: <AppNotification>[notification('a')],
                  hasMore: false,
                ),
              );

        final NotificationsCubit cubit = await _pump(tester, repository);
        await tester.tap(find.text(Strings.markAllRead));
        await tester.pumpAndSettle();

        expect(repository.markAllCalls, 1);
        expect((cubit.state as NotificationsLoaded).hasUnread, isFalse);
        expect(tester.takeException(), isNull);
      });

      testWidgets('an empty inbox says so', (WidgetTester tester) async {
        await _pump(tester, FakeNotificationsRepository());

        expect(find.text(Strings.noNotifications), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
