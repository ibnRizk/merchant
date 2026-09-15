import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/login_text_field.dart';

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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الجوال';
    }
    if (!RegExp(r'^05\d{8}$').hasMatch(value.trim())) {
      return 'رقم الجوال غير صحيح';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FA),
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: const Padding(
            padding: EdgeInsets.only(right: 16),
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
                  const Text(
                    'نسيت كلمة المرور؟',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: BrandColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الرجاء إدخال رقم الجوال المرتبط بحسابك لإرسال رمز التحقق.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LoginTextField(
                    label: 'رقم الجوال',
                    controller: _phoneController,
                    hintText: '05X XXX XXXX',
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(label: 'إرسال رمز التحقق', onPressed: _submit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
