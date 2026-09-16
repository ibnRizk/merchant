import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/app_form_field.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/primary_button.dart';

/// Forgot-password screen: phone entry step for requesting an OTP.
/// Self-contained, matching the login screen's visual language.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  AppColors get colors => context.colors;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.enterMobileNumber;
    }
    if (value.length < 9) {
      return Strings.invalidPhone;
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.pushNamed(AppRoutes.otpName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
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
                Center(
                  child: Text(
                    Strings.forgotPassword,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  Strings.enterMobileToReset,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5,
                    height: 1.5,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppFormField(
                  controller: _phoneController,
                  label: Strings.mobileNumber,
                  hintText: '05X XXX XXXX',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: Strings.sendVerificationCode, onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
