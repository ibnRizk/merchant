import 'package:flutter/material.dart';

import '../../../../core/utils/values/brand_colors.dart';
import '../../../../core/widgets/brand_back_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/resend_code_timer.dart';

/// OTP verification screen, reached after requesting a code from
/// [ForgotPasswordScreen]. Self-contained, matching the login flow's visual
/// language.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _codeLength = 4;

  String _code = '';

  void _submit() {
    if (_code.length != _codeLength) return;
    // TODO: verify code.
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 12),
                const Text(
                  'رمز التحقق',
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
                  'الرجاء إدخال الرمز المكون من 4 أرقام المرسل إلى جوالك',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                OtpInputRow(
                  length: _codeLength,
                  onChanged: (String value) => _code = value,
                  onCompleted: (String value) => _code = value,
                ),
                const SizedBox(height: 20),
                ResendCodeTimer(onResend: () {}),
                const SizedBox(height: 32),
                PrimaryButton(label: 'تأكيد', onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
