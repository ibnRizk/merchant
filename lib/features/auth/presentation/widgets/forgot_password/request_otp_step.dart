import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/validator.dart';
import '../../../../../core/utils/values/strings.dart';
import '../../../../../core/widgets/app_form_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../cubit/forgot_password/forgot_password_cubit.dart';
import '../auth_step_header.dart';

/// Step 1: ask for the account e-mail and send the reset OTP.
class RequestOtpStep extends StatefulWidget {
  const RequestOtpStep({super.key});

  @override
  State<RequestOtpStep> createState() => _RequestOtpStepState();
}

class _RequestOtpStepState extends State<RequestOtpStep> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Prefilled when the user comes back from the OTP step.
  late final TextEditingController _emailController = TextEditingController(
    text: context.read<ForgotPasswordCubit>().state.email,
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordCubit>().requestOtp(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AuthStepHeader(
            title: Strings.forgotPassword,
            subtitle: Strings.enterEmailToReset,
          ),
          const SizedBox(height: 32),
          AppFormField(
            controller: _emailController,
            label: Strings.email,
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (String? value) =>
                Validator.call(value: value, type: ValidatorType.email),
          ),
          const SizedBox(height: 24),
          BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
            selector: (ForgotPasswordState state) => state.isLoading,
            builder: (BuildContext context, bool isLoading) => PrimaryButton(
              label: Strings.sendVerificationCode,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
