import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/price_format.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/refresh_poller.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../profile/presentation/cubit/profile/profile_cubit.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/greeting_period.dart';
import '../cubit/dashboard/dashboard_cubit.dart';
import '../cubit/store_status/store_status_cubit.dart';
import '../widgets/attention_section_header.dart';
import '../widgets/home_header.dart';
import '../widgets/needs_attention_list.dart';
import '../widgets/stats_grid.dart';
import '../widgets/store_status_bar.dart';

/// Merchant dashboard, the "الرئيسية" tab of [MainScaffold]. Store name and
/// open status come from [ProfileCubit]; [DashboardCubit] and
/// [StoreStatusCubit] are provided by the home route.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // The profile may have loaded before this tab was first built.
    _seedStoreStatus(context.read<ProfileCubit>().state);
  }

  void _seedStoreStatus(ProfileState state) {
    final bool? isOpen = state is ProfileReady
        ? state.profile.store?.isOpen
        : null;
    if (isOpen != null) context.read<StoreStatusCubit>().seed(isOpen: isOpen);
  }

  Future<void> _openOrders(String routeName) async {
    final DashboardCubit dashboard = context.read<DashboardCubit>();
    await context.pushNamed(routeName);
    // Orders may have been accepted or moved on that screen.
    if (!dashboard.isClosed) dashboard.refresh();
  }

  Future<void> _refresh() {
    final ProfileCubit profile = context.read<ProfileCubit>();
    if (profile.state is ProfileLoadFailure) profile.loadProfile();
    return context.read<DashboardCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Labels come from the global `Strings.*.tr`, so a language switch has
    // to rebuild this screen for them to refresh.
    context.watch<LocaleCubit>();

    return MultiBlocListener(
      listeners: [
        // Only fresh server copies: a failed or no-op save re-emits the old
        // profile, which could undo a toggle made since.
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: (_, ProfileState current) =>
              current is ProfileLoaded || current is ProfileSaved,
          listener: (_, ProfileState state) => _seedStoreStatus(state),
        ),
        BlocListener<StoreStatusCubit, StoreStatusState>(
          listenWhen: (StoreStatusState previous, StoreStatusState current) =>
              current.failure != null &&
              !identical(previous.failure, current.failure),
          listener: (BuildContext context, StoreStatusState state) =>
              showBrandSnackBar(context, state.failure!.message, isError: true),
        ),
        BlocListener<DashboardCubit, DashboardState>(
          listenWhen: (DashboardState previous, DashboardState current) =>
              current is DashboardLoaded &&
              current.refreshFailure != null &&
              (previous is! DashboardLoaded ||
                  !identical(previous.refreshFailure, current.refreshFailure)),
          listener: (BuildContext context, DashboardState state) =>
              showBrandSnackBar(
                context,
                (state as DashboardLoaded).refreshFailure!.message,
                isError: true,
              ),
        ),
      ],
      child: RefreshPoller(
        onRefresh: context.read<DashboardCubit>().poll,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: context.colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: <Widget>[
                BlocSelector<ProfileCubit, ProfileState, String>(
                  selector: (ProfileState state) => state is ProfileReady
                      ? state.profile.store?.name ?? ''
                      : '',
                  builder: (BuildContext context, String storeName) =>
                      HomeHeader(
                        greeting: switch (GreetingPeriod.of(DateTime.now())) {
                          GreetingPeriod.morning => Strings.goodMorning,
                          GreetingPeriod.evening => Strings.goodEvening,
                        },
                        storeName: storeName,
                      ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<StoreStatusCubit, StoreStatusState>(
                  builder: (BuildContext context, StoreStatusState state) =>
                      StoreStatusBar(
                        isOpen: state.isOpen,
                        isUpdating: state.isUpdating,
                        onChanged: context.read<StoreStatusCubit>().setOpen,
                      ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: _buildDashboard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardState state) {
    final DashboardStats? stats = state is DashboardLoaded ? state.stats : null;
    // A dash while loading or failed, rather than a misleading zero.
    String figure(num? value) => value == null ? '–' : '$value';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        StatsGrid(
          ordersToday: figure(stats?.ordersToday),
          newOrders: figure(stats?.newOrders),
          revenueToday: stats == null ? '–' : formatPrice(stats.revenueToday),
          preparingOrders: figure(stats?.processingOrders),
        ),
        const SizedBox(height: 28),
        AttentionSectionHeader(
          title: Strings.needsAttention,
          actionLabel: Strings.viewAll,
          onActionTap: () => _openOrders(AppRoutes.newOrdersName),
        ),
        const SizedBox(height: 12),
        switch (state) {
          DashboardLoading() => const SectionLoadingView(height: 120),
          DashboardLoadFailure(:final message) => RetryErrorView(
            message: message,
            onRetry: context.read<DashboardCubit>().load,
          ),
          DashboardLoaded(:final stats) => NeedsAttentionList(
            stats: stats,
            onOpenNewOrders: () => _openOrders(AppRoutes.newOrdersName),
            onOpenActiveOrders: () => _openOrders(AppRoutes.activeOrdersName),
          ),
        },
      ],
    );
  }
}
