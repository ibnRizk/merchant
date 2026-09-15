import 'package:flutter/material.dart';

import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../widgets/menu_screen_header.dart';
import '../widgets/product_card.dart';

/// Menu management tab body — composed from small widgets under
/// `presentation/widgets/`. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const List<ProductEntry> _products = <ProductEntry>[
    ProductEntry(
      name: 'وجبة برجر SSM',
      subtitle: 'إضافات: جبنة، صوص',
      price: '28 ر.س',
      isAvailable: true,
      statusLabel: 'متوفر',
    ),
    ProductEntry(
      name: 'بطاطس مقرمشة',
      subtitle: 'إضافات: حار، جبنة',
      price: '8 ر.س',
      isAvailable: true,
      statusLabel: 'متوفر',
    ),
    ProductEntry(
      name: 'مشروب غازي',
      subtitle: 'حجم: صغير - كبير',
      price: '5 ر.س',
      isAvailable: false,
      statusLabel: 'غير متوفر',
    ),
    ProductEntry(
      name: 'وجبة عائلية',
      subtitle: '4 برجر - بطاطس - مشروبات',
      price: '52 ر.س',
      isAvailable: true,
      statusLabel: 'متوفر',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MenuScreenHeader(
              title: 'إدارة المنيو',
              addLabel: 'منتج',
              onAddTap: () {},
            ),
            const SizedBox(height: 16),
            AppSearchField(
              controller: _searchController,
              hintText: 'ابحث عن منتج',
            ),
            const SizedBox(height: 16),
            for (final ProductEntry entry in _products) ...<Widget>[
              ProductCard(entry: entry, onEdit: () {}, onMoreTap: () {}),
              const SizedBox(height: 12),
            ],
            const TipBanner(
              boldPrefix: 'نصيحة: ',
              text: 'أوقف المنتج مؤقتاً عندما لا يكون متوفراً حتى لا يستلمه العملاء بالخطأ.',
            ),
          ],
        ),
      ),
    );
  }
}
