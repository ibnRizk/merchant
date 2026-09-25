import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/status_views.dart';
import '../../domain/entities/merchant_order.dart';
import '../cubit/orders_history/orders_history_cubit.dart';
import '../utils/order_notice_messages.dart';
import '../widgets/history_filter_tabs.dart';
import '../widgets/order_history_card.dart';
import '../widgets/order_history_header.dart';
import '../widgets/orders_list_states.dart';

/// Order history tab body, rendered inside [MainScaffold]. [OrdersHistoryCubit]
/// is provided by the home route.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  static const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: 20);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  OrdersHistoryCubit get _cubit => context.read<OrdersHistoryCubit>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      _cubit.loadMore();
    }
  }

  Future<void> _openDetails(MerchantOrder order) async {
    await context.pushNamed(
      AppRoutes.orderDetailsName,
      pathParameters: <String, String>{'id': '${order.id}'},
    );
    // The order may have moved on the details screen.
    if (mounted) _cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Labels come from the global `Strings.*.tr`, so a language switch has
    // to rebuild this screen for them to refresh.
    context.watch<LocaleCubit>();

    return BlocListener<OrdersHistoryCubit, OrdersHistoryState>(
      listenWhen: (OrdersHistoryState previous, OrdersHistoryState current) =>
          current is OrdersHistoryLoaded &&
          isNewNotice(
            previous is OrdersHistoryLoaded ? previous.notice : null,
            current.notice,
          ),
      listener: (BuildContext context, OrdersHistoryState state) =>
          showOrderNotice(
            context,
            state is OrdersHistoryLoaded ? state.notice : null,
          ),
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
                      OrderHistoryHeader(
                        title: Strings.orderHistory,
                        exportLabel: Strings.export,
                        onExportTap: () => showBrandSnackBar(
                          context,
                          Strings.exportComingSoon,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppSearchField(
                        controller: _searchController,
                        hintText: Strings.searchOrderNumber,
                        onChanged: _cubit.search,
                      ),
                      const SizedBox(height: 16),
                      BlocSelector<
                        OrdersHistoryCubit,
                        OrdersHistoryState,
                        OrderFilter
                      >(
                        selector: (OrdersHistoryState state) => state.filter,
                        builder: (BuildContext context, OrderFilter filter) =>
                            HistoryFilterTabs(
                              labels: <String>[
                                Strings.allOrders,
                                Strings.completed,
                                Strings.cancelled,
                              ],
                              selectedIndex: filter.index,
                              onChanged: (int index) => _cubit.selectFilter(
                                OrderFilter.values[index],
                              ),
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              BlocBuilder<OrdersHistoryCubit, OrdersHistoryState>(
                builder: _buildBody,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersHistoryState state) {
    return switch (state) {
      OrdersHistoryLoading() => const SliverFillRemaining(
        hasScrollBody: false,
        child: SectionLoadingView(),
      ),
      OrdersHistoryLoadFailure(:final message) => SliverPadding(
        padding: _gutter,
        sliver: SliverToBoxAdapter(
          child: RetryErrorView(message: message, onRetry: _cubit.load),
        ),
      ),
      OrdersHistoryLoaded(:final visibleOrders, :final query)
          when visibleOrders.isEmpty && !state.hasMore =>
        SliverFillRemaining(
          hasScrollBody: false,
          child: OrdersEmptyView(
            message: Strings.noOrdersYet,
            isSearching: query.isNotEmpty,
          ),
        ),
      OrdersHistoryLoaded(:final visibleOrders) => SliverPadding(
        padding: _gutter.copyWith(bottom: 24),
        sliver: SliverList.separated(
          // One extra slot for the pagination footer.
          itemCount: visibleOrders.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            if (index == visibleOrders.length) {
              return OrdersListFooter(
                hasMore: state.hasMore,
                isLoadingMore: state.isLoadingMore,
                loadMoreFailed: state.loadMoreFailed,
                onLoadMore: () => _cubit.loadMore(retry: true),
              );
            }
            final MerchantOrder order = visibleOrders[index];
            return OrderHistoryCard(
              key: ValueKey<int>(order.id),
              order: order,
              onTap: () => _openDetails(order),
            );
          },
        ),
      ),
    };
  }
}
