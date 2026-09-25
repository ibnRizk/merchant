import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/merchant_auth_result.dart';
import '../widgets/auth_step_header.dart';

/// Shown after login when the account is not approved yet. Operational
/// routes return 403 until an admin approves it.
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key, required this.status});

  final MerchantApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final bool isRejected = status == MerchantApprovalStatus.rejected;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(
                isRejected
                    ? Icons.cancel_outlined
                    : Icons.hourglass_top_rounded,
                size: 72,
                color: isRejected ? colors.error : colors.primary,
              ),
              const SizedBox(height: 24),
              AuthStepHeader(
                title: isRejected
                    ? Strings.accountRejectedTitle
                    : Strings.accountPendingTitle,
                subtitle: isRejected
                    ? Strings.accountRejectedBody
                    : Strings.accountPendingBody,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: Strings.backToLogin,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
