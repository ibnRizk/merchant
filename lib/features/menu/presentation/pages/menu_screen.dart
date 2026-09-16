import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/show_modal_bottom_sheet.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../widgets/menu_screen_header.dart';
import '../widgets/product_card.dart';
import '../widgets/product_options_sheet.dart';

/// Menu management tab body — composed from small widgets under
/// `presentation/widgets/`. Rendered inside [MainScaffold]; the bottom nav
/// bar and RTL directionality are provided by the parent scaffold.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showProductOptions(
    BuildContext context,
    ProductEntry entry,
  ) async {
    await showAppModalBottomSheet(
      context: context,
      child: ProductOptionsSheet(
        onEdit: () {
          Navigator.of(context).pop();
          context.pushNamed(AppRoutes.addProductName, extra: entry);
        },
        onDelete: () {
          Navigator.of(context).pop();
          showBrandSnackBar(context, 'تم حذف ${entry.name}', isError: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductEntry> products = <ProductEntry>[
      ProductEntry(
        name: 'وجبة برجر SSM',
        subtitle: '${Strings.additions}جبنة، صوص',
        price: '28 ${Strings.currencySar}',
        isAvailable: true,
        statusLabel: Strings.available,
        addOns: const <String>['جبنة', 'صوص'],
      ),
      ProductEntry(
        name: 'بطاطس مقرمشة',
        subtitle: '${Strings.additions}حار، جبنة',
        price: '8 ${Strings.currencySar}',
        isAvailable: true,
        statusLabel: Strings.available,
        addOns: const <String>['حار', 'جبنة'],
      ),
      ProductEntry(
        name: 'مشروب غازي',
        subtitle: '${Strings.size}صغير - كبير',
        price: '5 ${Strings.currencySar}',
        isAvailable: false,
        statusLabel: Strings.unavailable,
        addOns: const <String>['صغير', 'كبير'],
      ),
      ProductEntry(
        name: 'وجبة عائلية',
        subtitle: '4 برجر - بطاطس - مشروبات',
        price: '52 ${Strings.currencySar}',
        isAvailable: true,
        statusLabel: Strings.available,
      ),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MenuScreenHeader(
              title: Strings.menuManagement,
              addLabel: Strings.addProduct,
              onAddTap: () => context.pushNamed(AppRoutes.addProductName),
            ),
            const SizedBox(height: 16),
            AppSearchField(
              controller: _searchController,
              hintText: Strings.searchProduct,
            ),
            const SizedBox(height: 16),
            for (final ProductEntry entry in products) ...<Widget>[
              ProductCard(
                entry: entry,
                onEdit: () =>
                    context.pushNamed(AppRoutes.addProductName, extra: entry),
                onMoreTap: () => _showProductOptions(context, entry),
              ),
              const SizedBox(height: 12),
            ],
            TipBanner(
              boldPrefix: Strings.tip,
              text: Strings.pauseProductTip,
            ),
          ],
        ),
      ),
    );
  }
}
