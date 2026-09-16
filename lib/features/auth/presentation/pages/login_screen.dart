import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/free_trial_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/login_header_text.dart';
import '../widgets/login_logo.dart';
import '../widgets/login_method_switcher.dart';

/// Merchant login screen — composed from small widgets under
/// `presentation/widgets/`. RTL is applied once here and inherited by every
/// child. `fontFamily: 'Cairo'` assumes the font is (or will be) registered
/// under `flutter > fonts` in pubspec.yaml.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginMethod _method = LoginMethod.phone;
  bool _obscurePassword = true;

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _method == LoginMethod.phone
          ? Strings.enterMobileNumber
          : Strings.enterUsername;
    }
    if (_method == LoginMethod.phone &&
        !RegExp(r'^0\d{9,14}$').hasMatch(value.trim())) {
      return Strings.invalidPhone;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.enterPassword;
    }
    if (value.length < 6) {
      return Strings.passwordTooShort;
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                LoginMethodSwitcher(
                  selected: _method,
                  onChanged: (LoginMethod method) =>
                      setState(() => _method = method),
                ),
                const SizedBox(height: 24),
                AppFormField(
                  controller: _identifierController,
                  label: _method == LoginMethod.phone
                      ? Strings.mobileNumber
                      : Strings.username,
                  hintText: _method == LoginMethod.phone
                      ? '05X XXX XXXX'
                      : Strings.username,
                  keyboardType: _method == LoginMethod.phone
                      ? TextInputType.phone
                      : TextInputType.text,
                  validator: _validateIdentifier,
                ),
                const SizedBox(height: 16),
                AppFormField(
                  controller: _passwordController,
                  label: Strings.password,
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: context.colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: Strings.login, onPressed: _submit),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        context.pushNamed(AppRoutes.forgotPasswordName),
                    child: Text(
                      Strings.forgotPassword,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FreeTrialBanner(text: Strings.freeTrialBanner),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
