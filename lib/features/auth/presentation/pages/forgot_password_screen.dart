import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../cubit/forgot_password/forgot_password_cubit.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/forgot_password/request_otp_step.dart';
import '../widgets/forgot_password/reset_password_step.dart';
import '../widgets/forgot_password/verify_otp_step.dart';

/// Hosts the 3-step password reset. [ForgotPasswordCubit] owns the current
/// step; back (app bar or system) goes to the previous step before leaving.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    switch (state.status) {
      case ForgotPasswordStatus.failure:
        showBrandSnackBar(
          context,
          state.errorMessage ?? Strings.somethingWentWrong,
          isError: true,
        );
      case ForgotPasswordStatus.otpResent:
        showBrandSnackBar(context, Strings.codeResent);
      case ForgotPasswordStatus.completed:
        showBrandSnackBar(context, Strings.passwordUpdatedSuccess);
        context.go(AppRoutes.splash);
      case ForgotPasswordStatus.idle || ForgotPasswordStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (ForgotPasswordState previous, ForgotPasswordState current) =>
          previous.status != current.status,
      listener: _onStateChanged,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: const AuthAppBar(),
        body: SafeArea(
          child:
              BlocSelector<
                ForgotPasswordCubit,
                ForgotPasswordState,
                ForgotPasswordStep
              >(
                selector: (ForgotPasswordState state) => state.step,
                builder: (BuildContext context, ForgotPasswordStep step) {
                  return PopScope(
                    canPop: step == ForgotPasswordStep.requestOtp,
                    onPopInvokedWithResult: (bool didPop, _) {
                      if (!didPop) context.read<ForgotPasswordCubit>().back();
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: switch (step) {
                          ForgotPasswordStep.requestOtp => const RequestOtpStep(
                            key: ValueKey<ForgotPasswordStep>(
                              ForgotPasswordStep.requestOtp,
                            ),
                          ),
                          ForgotPasswordStep.verifyOtp => const VerifyOtpStep(
                            key: ValueKey<ForgotPasswordStep>(
                              ForgotPasswordStep.verifyOtp,
                            ),
                          ),
                          ForgotPasswordStep.resetPassword =>
                            const ResetPasswordStep(
                              key: ValueKey<ForgotPasswordStep>(
                                ForgotPasswordStep.resetPassword,
                              ),
                            ),
                        },
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}
