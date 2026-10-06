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
import '../widgets/new_order_detail_card.dart';
import '../widgets/order_live_banner.dart';
import '../widgets/orders_list_states.dart';
import '../widgets/orders_screen_header.dart';
import '../widgets/ready_for_pickup_banner.dart';
import '../widgets/reject_order_sheet.dart';

/// New orders (`pending_merchant`), reached by pushing
/// `AppRoutes.newOrdersName`. [CurrentOrdersCubit] is provided by the route.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final CurrentOrdersCubit cubit = context.read<CurrentOrdersCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<CurrentOrdersCubit, CurrentOrdersState>(
        listenWhen: _hasNewNotice,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          BlocSelector<
                            CurrentOrdersCubit,
                            CurrentOrdersState,
                            int?
                          >(
                            selector: (CurrentOrdersState state) =>
                                state is CurrentOrdersLoaded
                                ? state.newOrders.length
                                : null,
                            builder: (BuildContext context, int? count) =>
                                OrdersScreenHeader(
                                  title: Strings.newOrdersTitle,
                                  badgeText: count == null
                                      ? null
                                      : '$count ${Strings.waiting}',
                                  leading: const BrandBackButton(),
                                ),
                          ),
                          const SizedBox(height: 16),
                          OrderLiveBanner(
                            title: Strings.directFromCustomer,
                            subtitle: Strings.managementMonitors,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const _NewOrdersList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewOrdersList extends StatelessWidget {
  const _NewOrdersList();

  static const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: 20);

  Future<void> _reject(BuildContext context, MerchantOrder order) async {
    final CurrentOrdersCubit cubit = context.read<CurrentOrdersCubit>();
    final RejectDecision? decision = await showRejectOrderSheet(context);
    if (decision == null || cubit.isClosed) return;
    cubit.reject(order, reason: decision.reason, note: decision.note);
  }

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
    final CurrentOrdersCubit cubit = context.read<CurrentOrdersCubit>();
    return BlocBuilder<CurrentOrdersCubit, CurrentOrdersState>(
      builder: (BuildContext context, CurrentOrdersState state) =>
          switch (state) {
            CurrentOrdersLoading() => const SliverFillRemaining(
              hasScrollBody: false,
              child: SectionLoadingView(),
            ),
            CurrentOrdersLoadFailure(:final message) => SliverPadding(
              padding: _gutter,
              sliver: SliverToBoxAdapter(
                child: RetryErrorView(message: message, onRetry: cubit.load),
              ),
            ),
            CurrentOrdersLoaded(:final newOrders) when newOrders.isEmpty =>
              SliverFillRemaining(
                hasScrollBody: false,
                child: OrdersEmptyView(message: Strings.noNewOrders),
              ),
            CurrentOrdersLoaded(:final newOrders, :final busyIds) =>
              SliverPadding(
                padding: _gutter.copyWith(bottom: 24),
                sliver: SliverList.separated(
                  // One extra slot for the "after ready for pickup" banner.
                  itemCount: newOrders.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == newOrders.length) {
                      return ReadyForPickupBanner(
                        prefix: Strings.afterPressing,
                        highlighted: Strings.readyForPickupQuoted,
                        subtitle: Strings.systemWillNotifyDriver,
                      );
                    }
                    final MerchantOrder order = newOrders[index];
                    return NewOrderDetailCard(
                      key: ValueKey<int>(order.id),
                      order: order,
                      isBusy: busyIds.contains(order.id),
                      onAccept: () => cubit.accept(order),
                      onReject: () => _reject(context, order),
                      onTap: () => _openDetails(context, order),
                    );
                  },
                ),
              ),
          },
    );
  }
}

bool _hasNewNotice(CurrentOrdersState previous, CurrentOrdersState current) =>
    current is CurrentOrdersLoaded &&
    isNewNotice(
      previous is CurrentOrdersLoaded ? previous.notice : null,
      current.notice,
    );
