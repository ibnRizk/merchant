import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/show_modal_bottom_sheet.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../../domain/entities/product.dart';
import '../cubit/menu/menu_cubit.dart';
import '../widgets/menu_list_states.dart';
import '../widgets/menu_screen_header.dart';
import '../widgets/product_card.dart';
import '../widgets/product_options_sheet.dart';

/// Menu management tab body, rendered inside [MainScaffold]. [MenuCubit] is
/// provided by the home route.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  static const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: 20);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchTimer;

  MenuCubit get _cubit => context.read<MenuCubit>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      _cubit.loadMore();
    }
  }

  /// Waits for a pause in typing so each keystroke isn't a request.
  void _onSearchChanged(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () => _cubit.search(text));
  }

  Future<void> _openForm([Product? product]) async {
    final Product? saved = await context.pushNamed<Product>(
      AppRoutes.productFormName,
      extra: product,
    );
    if (saved != null && mounted) _cubit.productSaved(saved);
  }

  Future<void> _confirmDelete(Product product) async {
    final bool confirmed = await showConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      title: Strings.deleteProductConfirmTitle,
      message: Strings.deleteProductConfirmMessage,
      confirmLabel: Strings.deleteProduct,
    );
    if (confirmed && mounted) _cubit.deleteProduct(product);
  }

  void _showOptions(Product product) {
    showAppModalBottomSheet(
      context: context,
      child: Builder(
        builder: (BuildContext sheetContext) => ProductOptionsSheet(
          productName: product.name,
          onEdit: () {
            Navigator.of(sheetContext).pop();
            _openForm(product);
          },
          onEditOptions: () {
            Navigator.of(sheetContext).pop();
            context.pushNamed(AppRoutes.productOptionsName, extra: product);
          },
          onDelete: () {
            Navigator.of(sheetContext).pop();
            _confirmDelete(product);
          },
        ),
      ),
    );
  }

  static bool _hasNewNotice(MenuState previous, MenuState current) =>
      current is MenuLoaded &&
      current.notice != null &&
      (previous is! MenuLoaded || !identical(previous.notice, current.notice));

  void _onNotice(BuildContext context, MenuState state) {
    final MenuNotice? notice = state is MenuLoaded ? state.notice : null;
    switch (notice) {
      case ProductDeletedNotice():
        showBrandSnackBar(context, Strings.productDeleted);
      case ProductDeleteBlockedNotice():
        showBrandSnackBar(
          context,
          Strings.productLinkedToOrders,
          isError: true,
          duration: const Duration(seconds: 5),
        );
      case MenuActionFailedNotice(:final message):
        showBrandSnackBar(context, message, isError: true);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Labels come from the global `Strings.*.tr`, so a language switch has
    // to rebuild this screen for them to refresh.
    context.watch<LocaleCubit>();

    return BlocListener<MenuCubit, MenuState>(
      listenWhen: _hasNewNotice,
      listener: _onNotice,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _cubit.refresh,
          color: context.colors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: <Widget>[
              SliverPadding(
                padding: _gutter.copyWith(top: 12),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MenuScreenHeader(
                        title: Strings.menuManagement,
                        addLabel: Strings.addProduct,
                        onAddTap: _openForm,
                      ),
                      const SizedBox(height: 16),
                      AppSearchField(
                        controller: _searchController,
                        hintText: Strings.searchProduct,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              BlocBuilder<MenuCubit, MenuState>(builder: _buildBody),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MenuState state) {
    return switch (state) {
      MenuLoading() => const SliverFillRemaining(
        hasScrollBody: false,
        child: SectionLoadingView(),
      ),
      MenuLoadFailure(:final message) => SliverPadding(
        padding: _gutter,
        sliver: SliverToBoxAdapter(
          child: RetryErrorView(message: message, onRetry: _cubit.load),
        ),
      ),
      MenuLoaded(:final products, :final query) when products.isEmpty =>
        SliverFillRemaining(
          hasScrollBody: false,
          child: MenuEmptyView(
            isSearching: query.isNotEmpty,
            onAddTap: _openForm,
          ),
        ),
      MenuLoaded() => SliverPadding(
        padding: _gutter.copyWith(bottom: 24),
        sliver: SliverList.separated(
          // One extra slot for the footer (spinner/retry + tip).
          itemCount: state.products.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            if (index == state.products.length) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MenuListFooter(
                    isLoadingMore: state.isLoadingMore,
                    loadMoreFailed: state.loadMoreFailed,
                    onRetry: () => _cubit.loadMore(retry: true),
                  ),
                  if (!state.hasMore)
                    TipBanner(
                      boldPrefix: Strings.tip,
                      text: Strings.pauseProductTip,
                    ),
                ],
              );
            }
            final Product product = state.products[index];
            return ProductCard(
              key: ValueKey<int>(product.id),
              product: product,
              isBusy: state.busyIds.contains(product.id),
              onTap: () => _openForm(product),
              onAvailabilityChanged: (bool isActive) =>
                  _cubit.toggleStatus(product, isActive: isActive),
              onMoreTap: () => _showOptions(product),
            );
          },
        ),
      ),
    };
  }
}
