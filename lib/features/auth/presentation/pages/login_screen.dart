import 'package:flutter/material.dart';

/// Merchant login screen — self-contained Presentation-layer UI.
///
/// Uses standard Flutter widgets only. `fontFamily: 'Cairo'` assumes the
/// font is (or will be) registered under `flutter > fonts` in pubspec.yaml;
/// until then Flutter silently falls back to the platform default.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _LoginMethod { username, phone }

class _LoginScreenState extends State<LoginScreen> {
  static const Color _navy = Color(0xFF173C66);
  static const Color _orange = Color(0xFFF6921E);
  static const Color _fieldFill = Color(0xFFF5F6F8);
  static const Color _hintGray = Color(0xFFAAB2BD);
  static const Color _bannerBg = Color(0xFFE9F7EF);
  static const Color _bannerText = Color(0xFF2E9E5B);

  _LoginMethod _method = _LoginMethod.phone;
  bool _obscurePassword = true;

  final TextEditingController _identifierController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 16),
                _buildLogo(),
                const SizedBox(height: 20),
                const Text(
                  'أهلاً بك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'سجّل الدخول لإدارة متجرك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                _buildMethodSwitcher(),
                const SizedBox(height: 24),
                _buildFieldLabel(
                  _method == _LoginMethod.phone
                      ? 'رقم الجوال'
                      : 'اسم المستخدم',
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _identifierController,
                  hintText: _method == _LoginMethod.phone
                      ? '05X XXX XXXX'
                      : 'اسم المستخدم',
                  keyboardType: _method == _LoginMethod.phone
                      ? TextInputType.phone
                      : TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildFieldLabel('كلمة المرور'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _hintGray,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildLoginButton(),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildFreeTrialBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _navy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'SSM',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          _buildMethodTab(
            label: 'اسم المستخدم',
            method: _LoginMethod.username,
          ),
          _buildMethodTab(
            label: 'رقم الجوال',
            method: _LoginMethod.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTab({
    required String label,
    required _LoginMethod method,
  }) {
    final bool isSelected = _method == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? _orange.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? _orange : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: _navy,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: _hintGray,
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E5EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E5EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _navy, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'تسجيل الدخول',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeTrialBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: _bannerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'المتاجر مجانية بدون رسوم في المرحلة الأولى.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: _bannerText,
        ),
      ),
    );
  }
}
