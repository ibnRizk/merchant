import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/validator.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/free_trial_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/login/login_cubit.dart';
import '../widgets/login_header_text.dart';
import '../widgets/login_logo.dart';
import '../widgets/password_form_field.dart';

/// Merchant login with e-mail and password (the API has no phone login).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) =>
      (value == null || value.isEmpty) ? Strings.enterPassword : null;

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    switch (state) {
      case LoginSuccess(:final result) when result.isApproved:
        context.go(AppRoutes.home);
      case LoginSuccess(:final result):
        context.go(AppRoutes.pendingApproval, extra: result.approvalStatus);
      case LoginFailure(:final message):
        showBrandSnackBar(context, message, isError: true);
      case LoginInitial() || LoginLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: _onStateChanged,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 16),
                  const LoginLogo(),
                  const SizedBox(height: 20),
                  const LoginHeaderText(),
                  const SizedBox(height: 28),
                  AppFormField(
                    controller: _emailController,
                    label: Strings.email,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) =>
                        Validator.call(value: value, type: ValidatorType.email),
                  ),
                  const SizedBox(height: 16),
                  PasswordFormField(
                    controller: _passwordController,
                    label: Strings.password,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  BlocSelector<LoginCubit, LoginState, bool>(
                    selector: (LoginState state) => state is LoginLoading,
                    builder: (BuildContext context, bool isLoading) =>
                        PrimaryButton(
                          label: Strings.login,
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _TextLink(
                    label: Strings.forgotPassword,
                    onTap: () =>
                        context.pushNamed(AppRoutes.forgotPasswordName),
                  ),
                  const SizedBox(height: 12),
                  _TextLink(
                    prefix: Strings.noAccount,
                    label: Strings.createStoreAccount,
                    onTap: () => context.pushNamed(AppRoutes.registerName),
                  ),
                  const SizedBox(height: 20),
                  FreeTrialBanner(text: Strings.freeTrialBanner),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap, this.prefix});

  final String label;
  final VoidCallback onTap;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (prefix != null) ...<Widget>[
          Text(
            prefix!,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
        ],
        GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
