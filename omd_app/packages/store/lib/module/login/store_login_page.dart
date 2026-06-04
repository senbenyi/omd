import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:store/module/a_color/store_colors.dart';
import 'package:store/common/user/go_user_controller.dart';
import 'package:store/module/login/store_login_i18n.dart';

/// 登录 / 注册页（Tab 切换，密码登录与注册）。
class StoreLoginPage extends StatefulWidget {
  const StoreLoginPage({super.key});

  @override
  State<StoreLoginPage> createState() => _StoreLoginPageState();
}

class _StoreLoginPageState extends State<StoreLoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final GoUserController _userController;

  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _registerPhoneController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userController = GoUserController.to;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _registerPhoneController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoreColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    StoreLoginI18n.appSubtitle.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: StoreColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: TabBar(
                controller: _tabController,
                labelColor: StoreColors.tabSelected,
                unselectedLabelColor: StoreColors.secondaryText,
                indicatorColor: StoreColors.tabSelected,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: StoreLoginI18n.tabLogin.tr),
                  Tab(text: StoreLoginI18n.tabRegister.tr),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLoginForm(), _buildRegisterForm()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPhoneField(
            controller: _loginPhoneController,
            hint: StoreLoginI18n.phoneHint.tr,
          ),
          SizedBox(height: 16.h),
          _buildPasswordField(
            controller: _loginPasswordController,
            hint: StoreLoginI18n.passwordHint.tr,
          ),
          SizedBox(height: 24.h),
          _buildPrimaryButton(
            label: StoreLoginI18n.loginButton.tr,
            onPressed: _onLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPhoneField(
            controller: _registerPhoneController,
            hint: StoreLoginI18n.phoneHint.tr,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            controller: _registerUsernameController,
            hint: StoreLoginI18n.usernameHint.tr,
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16.h),
          _buildPasswordField(
            controller: _registerPasswordController,
            hint: StoreLoginI18n.passwordHint.tr,
          ),
          SizedBox(height: 16.h),
          _buildPasswordField(
            controller: _registerConfirmPasswordController,
            hint: StoreLoginI18n.confirmPasswordHint.tr,
          ),
          SizedBox(height: 24.h),
          _buildPrimaryButton(
            label: StoreLoginI18n.registerButton.tr,
            onPressed: _onRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String hint,
  }) {
    return _buildTextField(
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
  }) {
    return _buildTextField(
      controller: controller,
      hint: hint,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(fontSize: 15.sp, color: StoreColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: StoreColors.secondaryText, fontSize: 15.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(
            color: StoreColors.tabSelected,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: StoreColors.tabSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    await _userController.loginWithPassword(
      phone: _loginPhoneController.text,
      password: _loginPasswordController.text,
    );
  }

  Future<void> _onRegister() async {
    final password = _registerPasswordController.text;
    final confirm = _registerConfirmPasswordController.text;
    if (password != confirm) {
      Get.snackbar(
        StoreLoginI18n.errorTitle.tr,
        StoreLoginI18n.passwordMismatch.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _userController.register(
      phone: _registerPhoneController.text,
      password: password,
      username: _registerUsernameController.text,
    );
  }
}
