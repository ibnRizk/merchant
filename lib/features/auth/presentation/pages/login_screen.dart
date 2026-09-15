import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/free_trial_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/login_header_text.dart';
import '../widgets/login_logo.dart';
import '../widgets/login_method_switcher.dart';
import '../widgets/login_text_field.dart';

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
          ? 'الرجاء إدخال رقم الجوال'
          : 'الرجاء إدخال اسم المستخدم';
    }
    if (_method == LoginMethod.phone &&
        !RegExp(r'^05\d{8}$').hasMatch(value.trim())) {
      return 'رقم الجوال غير صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور 6 أحرف على الأقل';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
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
                  LoginTextField(
                    label: _method == LoginMethod.phone
                        ? 'رقم الجوال'
                        : 'اسم المستخدم',
                    controller: _identifierController,
                    hintText: _method == LoginMethod.phone
                        ? '05X XXX XXXX'
                        : 'اسم المستخدم',
                    keyboardType: _method == LoginMethod.phone
                        ? TextInputType.phone
                        : TextInputType.text,
                    validator: _validateIdentifier,
                  ),
                  const SizedBox(height: 20),
                  LoginTextField(
                    label: 'كلمة المرور',
                    controller: _passwordController,
                    hintText: '••••••••',
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: BrandColors.hintGray,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(label: 'تسجيل الدخول', onPressed: _submit),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          context.pushNamed(AppRoutes.forgotPasswordName),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.orange,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FreeTrialBanner(
                    text: 'المتاجر مجانية بدون رسوم في المرحلة الأولى.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
