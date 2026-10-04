import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/entities/merchant_approval_status.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/tip_banner.dart';
import '../cubit/pending_approval/pending_approval_cubit.dart';
import '../widgets/auth_step_header.dart';

/// Shown while the account can't operate: after login, from the splash
/// screen, or when any request answers 403 `merchant-not-approved` /
/// `merchant-suspended`. [PendingApprovalCubit] is provided by the route.
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  void _onStateChanged(BuildContext context, PendingApprovalState state) {
    switch (state.status) {
      case PendingApprovalStatus.approved:
        context.go(AppRoutes.home);
      case PendingApprovalStatus.signedOut:
        context.go(AppRoutes.login);
      case PendingApprovalStatus.stillRestricted:
        showBrandSnackBar(context, Strings.accountStatusUnchanged);
      case PendingApprovalStatus.failure:
        showBrandSnackBar(
          context,
          state.errorMessage ?? Strings.somethingWentWrong,
          isError: true,
        );
      case PendingApprovalStatus.idle || PendingApprovalStatus.checking:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return BlocListener<PendingApprovalCubit, PendingApprovalState>(
      listenWhen: (PendingApprovalState previous, PendingApprovalState current) =>
          previous.status != current.status,
      listener: _onStateChanged,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: BlocBuilder<PendingApprovalCubit, PendingApprovalState>(
                builder: (BuildContext context, PendingApprovalState state) =>
                    _PendingContent(state: state),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingContent extends StatelessWidget {
  const _PendingContent({required this.state});

  final PendingApprovalState state;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final PendingApprovalCubit cubit = context.read<PendingApprovalCubit>();
    final (IconData icon, Color iconColor, String title, String body) =
        switch (state.approvalStatus) {
          MerchantApprovalStatus.rejected => (
            Icons.cancel_outlined,
            colors.error,
            Strings.accountRejectedTitle,
            Strings.accountRejectedBody,
          ),
          MerchantApprovalStatus.suspended => (
            Icons.block_rounded,
            colors.error,
            Strings.accountSuspendedTitle,
            Strings.accountSuspendedBody,
          ),
          MerchantApprovalStatus.pending ||
          MerchantApprovalStatus.approved => (
            Icons.hourglass_top_rounded,
            colors.primary,
            Strings.accountPendingTitle,
            Strings.accountPendingBody,
          ),
        };
    final String? reason = state.rejectionReason;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(icon, size: 72, color: iconColor),
        const SizedBox(height: 24),
        AuthStepHeader(title: title, subtitle: body),
        if (state.approvalStatus == MerchantApprovalStatus.rejected &&
            reason != null) ...<Widget>[
          const SizedBox(height: 20),
          TipBanner(boldPrefix: Strings.rejectionReasonPrefix, text: reason),
        ],
        const SizedBox(height: 32),
        PrimaryButton(
          label: Strings.checkAgain,
          isLoading: state.isChecking,
          onPressed: cubit.check,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: state.isChecking ? null : cubit.signOut,
          style: TextButton.styleFrom(foregroundColor: colors.error),
          child: Text(
            Strings.logout,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
