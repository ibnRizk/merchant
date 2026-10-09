import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/push_tap_router.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/realtime_listener.dart';
import '../../../../injection_container.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../../hours/presentation/pages/hours_screen.dart';
import '../../../menu/presentation/pages/menu_screen.dart';
import '../../../notifications/presentation/cubit/unread_count/unread_count_cubit.dart';
import '../../../orders/presentation/pages/order_history_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';

/// App hub: hosts the 5 bottom-nav tabs behind a single [Scaffold] so the
/// nav bar persists across tab switches. RTL is applied once here and
/// inherited by every tab body.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  /// Kept so dispose doesn't look it up in a deactivated tree.
  late final PushTapRouter _pushTapRouter =
      ServiceLocator.instance<PushTapRouter>();

  @override
  void initState() {
    super.initState();
    // `/vendor/config` needs a token, and reaching home means there is one.
    context.read<AppConfigCubit>().refresh();
    WidgetsBinding.instance.addObserver(this);
    // A notification tapped before home was up (e.g. the one that launched
    // the app) opens now, above home.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pushTapRouter.onHomeShown();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The socket may have slept in the background; the badge catches up.
    if (state == AppLifecycleState.resumed) {
      context.read<UnreadCountCubit>().refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pushTapRouter.onHomeHidden();
    super.dispose();
  }

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    OrderHistoryScreen(),
    MenuScreen(),
    HoursScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Watch LocaleCubit so the scaffold rebuilds when the language changes.
    context.watch<LocaleCubit>().state;

    final List<NavItemData> items = <NavItemData>[
      NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: Strings.navHome,
      ),
      NavItemData(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: Strings.navOrders,
      ),
      NavItemData(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: Strings.navMenu,
      ),
      NavItemData(
        icon: Icons.access_time_outlined,
        activeIcon: Icons.access_time,
        label: Strings.navHours,
      ),
      NavItemData(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: Strings.navProfile,
      ),
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      // Here rather than in a tab, so the badge stays current on every tab.
      body: RealtimeListener(
        when: (RealtimeEvent event) => event.affectsNotifications,
        onEvent: context.read<UnreadCountCubit>().refresh,
        child: IndexedStack(index: _selectedIndex, children: _tabs),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        selectedIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
