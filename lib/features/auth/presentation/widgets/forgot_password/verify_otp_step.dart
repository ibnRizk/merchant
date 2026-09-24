import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/values/strings.dart';
import '../../../../../core/widgets/brand_snack_bar.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../cubit/forgot_password/forgot_password_cubit.dart';
import '../auth_step_header.dart';
import '../otp_input_row.dart';
import '../resend_code_timer.dart';

/// Step 2: enter the OTP that was e-mailed.
class VerifyOtpStep extends StatefulWidget {
  const VerifyOtpStep({super.key});

  @override
  State<VerifyOtpStep> createState() => _VerifyOtpStepState();
}

class _VerifyOtpStepState extends State<VerifyOtpStep> {
  static const int _codeLength = 4;

  String _code = '';

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_code.length != _codeLength) {
      showBrandSnackBar(context, Strings.enterFullCode, isError: true);
      return;
    }
    context.read<ForgotPasswordCubit>().verifyOtp(_code);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AuthStepHeader(
          title: Strings.verificationCode,
          subtitle:
              '${Strings.enterCodeSentToEmail}\n'
              '${context.read<ForgotPasswordCubit>().state.email}',
        ),
        const SizedBox(height: 32),
        // OTP digits are always entered left-to-right, even in Arabic.
        Directionality(
          textDirection: TextDirection.ltr,
          child: OtpInputRow(
            length: _codeLength,
            onChanged: (String value) => _code = value,
            onCompleted: (String value) => _code = value,
          ),
        ),
        const SizedBox(height: 24),
        ResendCodeTimer(
          onResend: context.read<ForgotPasswordCubit>().resendOtp,
        ),
        const SizedBox(height: 24),
        BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
          selector: (ForgotPasswordState state) => state.isLoading,
          builder: (BuildContext context, bool isLoading) => PrimaryButton(
            label: Strings.confirm,
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
