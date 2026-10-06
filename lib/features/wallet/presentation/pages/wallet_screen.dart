import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/back_title_bar.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/status_views.dart';
import '../../../../core/widgets/surface_card.dart';
import '../../../app_config/presentation/cubit/app_config_cubit.dart';
import '../../domain/entities/wallet.dart';
import '../cubit/wallet_cubit.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/withdraw_request_tile.dart';
import '../widgets/withdraw_sheet.dart';

/// Balances and payouts, reached from the home screen. [WalletCubit] is
/// provided by the route.
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<void> _requestPayout(
    BuildContext context,
    WalletBalance balance,
  ) async {
    final WalletCubit cubit = context.read<WalletCubit>();
    final double? amount = await showWithdrawSheet(
      context,
      balance: balance,
      currency: context.read<AppConfigCubit>().state.currency,
    );
    if (amount != null && !cubit.isClosed) cubit.requestWithdrawal(amount);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocaleCubit>();
    final WalletCubit cubit = context.read<WalletCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<WalletCubit, WalletState>(
        listenWhen: (WalletState previous, WalletState current) =>
            current is WalletLoaded &&
            current.notice != null &&
            !identical(
              previous is WalletLoaded ? previous.notice : null,
              current.notice,
            ),
        listener: (BuildContext context, WalletState state) =>
            switch ((state as WalletLoaded).notice) {
              WithdrawRequestedNotice() => showBrandSnackBar(
                context,
                Strings.payoutRequested,
              ),
              WalletFailureNotice(:final message) => showBrandSnackBar(
                context,
                message,
                isError: true,
              ),
              null => null,
            },
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: cubit.refresh,
            color: context.colors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: <Widget>[
                BackTitleBar(title: Strings.walletTitle),
                const SizedBox(height: 20),
                BlocBuilder<WalletCubit, WalletState>(
                  builder: (BuildContext context, WalletState state) =>
                      switch (state) {
                        WalletLoading() => const SectionLoadingView(),
                        WalletLoadFailure(:final message) => RetryErrorView(
                          message: message,
                          onRetry: cubit.load,
                        ),
                        WalletLoaded() => _WalletBody(
                          state: state,
                          onRequestPayout: () =>
                              _requestPayout(context, state.overview.balance),
                        ),
                      },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody({required this.state, required this.onRequestPayout});

  final WalletLoaded state;
  final VoidCallback onRequestPayout;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final String currency = context.currency;
    final WalletBalance balance = state.overview.balance;
    final List<WithdrawRequest> withdrawals = state.overview.withdrawals;
    final bool canWithdraw =
        balance.availableBalance >= WalletBalance.minimumWithdrawal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        WalletBalanceCard(balance: balance, currency: currency),
        const SizedBox(height: 16),
        if (canWithdraw)
          PrimaryButton(
            label: Strings.requestPayout,
            isLoading: state.isSubmitting,
            onPressed: onRequestPayout,
          )
        else
          Text(
            Strings.noBalanceToWithdraw,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5,
              color: colors.textSecondary,
            ),
          ),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionTitle(Strings.payoutHistory),
              const SizedBox(height: 6),
              if (withdrawals.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    Strings.noPayoutsYet,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                )
              else
                for (int i = 0; i < withdrawals.length; i++) ...<Widget>[
                  if (i > 0) Divider(color: colors.border, height: 1),
                  WithdrawRequestTile(
                    request: withdrawals[i],
                    currency: currency,
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}
