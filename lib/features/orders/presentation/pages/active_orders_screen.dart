import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/refresh_poller.dart';
import '../../../../core/widgets/status_views.dart';
import '../../domain/entities/merchant_order.dart';
import '../cubit/current_orders/current_orders_cubit.dart';
import '../utils/order_notice_messages.dart';
import '../widgets/active_order_detail_card.dart';
import '../widgets/collapsed_active_order_card.dart';
import '../widgets/orders_list_states.dart';
import '../widgets/orders_screen_header.dart';

/// Accepted orders still in progress, reached by pushing
/// `AppRoutes.activeOrdersName`. Orders the merchant can still move get the
/// full card; handed-over ones (dispatch/delivery) a compact row.
/// [CurrentOrdersCubit] is provided by the route.
class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  static const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: 20);

  Future<void> _openDetails(BuildContext context, MerchantOrder order) async {
    final CurrentOrdersCubit cubit = context.read<CurrentOrdersCubit>();
    await context.pushNamed(
      AppRoutes.orderDetailsName,
      pathParameters: <String, String>{'id': '${order.id}'},
    );
    if (!cubit.isClosed) cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final CurrentOrdersCubit cubit = context.read<CurrentOrdersCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<CurrentOrdersCubit, CurrentOrdersState>(
        listenWhen: (CurrentOrdersState previous, CurrentOrdersState current) =>
            current is CurrentOrdersLoaded &&
            isNewNotice(
              previous is CurrentOrdersLoaded ? previous.notice : null,
              current.notice,
            ),
        listener: (BuildContext context, CurrentOrdersState state) =>
            showOrderNotice(
              context,
              state is CurrentOrdersLoaded ? state.notice : null,
            ),
        child: RefreshPoller(
          onRefresh: cubit.poll,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: cubit.refresh,
              color: context.colors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child:
                          BlocSelector<
                            CurrentOrdersCubit,
                            CurrentOrdersState,
                            int?
                          >(
                            selector: (CurrentOrdersState state) =>
                                state is CurrentOrdersLoaded
                                ? state.activeOrders.length
                                : null,
                            builder: (BuildContext context, int? count) =>
                                OrdersScreenHeader(
                                  title: Strings.activeOrdersTitle,
                                  badgeText: count == null
                                      ? null
                                      : '$count ${Strings.ordersCount}',
                                  leading: const BrandBackButton(),
                                ),
                          ),
                    ),
                  ),
                  BlocBuilder<CurrentOrdersCubit, CurrentOrdersState>(
                    builder: (BuildContext context, CurrentOrdersState state) =>
                        switch (state) {
                          CurrentOrdersLoading() => const SliverFillRemaining(
                            hasScrollBody: false,
                            child: SectionLoadingView(),
                          ),
                          CurrentOrdersLoadFailure(:final message) =>
                            SliverPadding(
                              padding: _gutter,
                              sliver: SliverToBoxAdapter(
                                child: RetryErrorView(
                                  message: message,
                                  onRetry: cubit.load,
                                ),
                              ),
                            ),
                          CurrentOrdersLoaded(:final activeOrders)
                              when activeOrders.isEmpty =>
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: OrdersEmptyView(
                                message: Strings.noActiveOrders,
                              ),
                            ),
                          CurrentOrdersLoaded(
                            :final activeOrders,
                            :final busyIds,
                          ) =>
                            SliverPadding(
                              padding: _gutter.copyWith(bottom: 24),
                              sliver: SliverList.separated(
                                itemCount: activeOrders.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (BuildContext context, int index) {
                                  final MerchantOrder order =
                                      activeOrders[index];
                                  if (order.status.nextAction == null) {
                                    return CollapsedActiveOrderCard(
                                      key: ValueKey<int>(order.id),
                                      order: order,
                                      onTap: () => _openDetails(context, order),
                                    );
                                  }
                                  return ActiveOrderDetailCard(
                                    key: ValueKey<int>(order.id),
                                    order: order,
                                    isBusy: busyIds.contains(order.id),
                                    onAdvance: () => cubit.advance(order),
                                    onTap: () => _openDetails(context, order),
                                  );
                                },
                              ),
                            ),
                        },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
