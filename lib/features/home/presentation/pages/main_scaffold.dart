import 'package:flutter/material.dart';

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

  static const List<NavItemData> _items = <NavItemData>[
    NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'الرئيسية',
    ),
    NavItemData(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'الطلبات',
    ),
    NavItemData(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'المنيو',
    ),
    NavItemData(
      icon: Icons.access_time_outlined,
      activeIcon: Icons.access_time,
      label: 'الساعات',
    ),
    NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'حسابي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: IndexedStack(index: _selectedIndex, children: _tabs),
        bottomNavigationBar: AppBottomNavBar(
          items: _items,
          selectedIndex: _selectedIndex,
          onTap: (int index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
