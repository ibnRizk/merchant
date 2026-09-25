import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../hours/presentation/pages/hours_screen.dart';
import '../../../menu/presentation/pages/menu_screen.dart';
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

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

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
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        selectedIndex: _selectedIndex,
        onTap: (int index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
