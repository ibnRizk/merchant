import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/primary_button.dart';

/// Final step of the forgot-password flow: set a new password after OTP
/// verification, then return to login.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.enterNewPassword;
    }
    if (value.length < 6) {
      return Strings.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.confirmPasswordError;
    }
    if (value != _passwordController.text) {
      return Strings.passwordsDoNotMatch;
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      showBrandSnackBar(
        context,
        Strings.passwordUpdatedSuccess,
        isError: false,
      );
      context.go(AppRoutes.splash);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsetsDirectional.only(start: 16),
          child: BrandBackButton(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 12),
                Text(
                  Strings.newPassword,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Strings.enterNewPasswordSubtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppFormField(
                  controller: _passwordController,
                  label: Strings.newPassword,
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),
                AppFormField(
                  controller: _confirmController,
                  label: Strings.confirmPassword,
                  hintText: '••••••••',
                  obscureText: _obscureConfirm,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: Strings.setPassword, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
