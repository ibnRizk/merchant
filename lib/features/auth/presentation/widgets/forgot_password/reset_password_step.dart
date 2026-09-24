import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/validator.dart';
import '../../../../../core/utils/values/strings.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../cubit/forgot_password/forgot_password_cubit.dart';
import '../auth_step_header.dart';
import '../password_form_field.dart';

/// Step 3: set the new password.
class ResetPasswordStep extends StatefulWidget {
  const ResetPasswordStep({super.key});

  @override
  State<ResetPasswordStep> createState() => _ResetPasswordStepState();
}

class _ResetPasswordStepState extends State<ResetPasswordStep> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return Strings.enterNewPassword;
    return Validator.call(value: value, type: ValidatorType.strongPassword);
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return Strings.confirmPasswordError;
    return value == _passwordController.text
        ? null
        : Strings.passwordsDoNotMatch;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordCubit>().resetPassword(
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AuthStepHeader(
            title: Strings.newPassword,
            subtitle: Strings.enterNewPasswordSubtitle,
          ),
          const SizedBox(height: 32),
          PasswordFormField(
            controller: _passwordController,
            label: Strings.newPassword,
            validator: _validatePassword,
          ),
          const SizedBox(height: 20),
          PasswordFormField(
            controller: _confirmController,
            label: Strings.confirmPassword,
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: 28),
          BlocSelector<ForgotPasswordCubit, ForgotPasswordState, bool>(
            selector: (ForgotPasswordState state) => state.isLoading,
            builder: (BuildContext context, bool isLoading) => PrimaryButton(
              label: Strings.setPassword,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
