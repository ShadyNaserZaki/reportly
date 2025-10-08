import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:reportly/screens/login_screen.dart';
import 'package:reportly/screens/reportly_dashboard.dart';
import 'package:reportly/theme_colors.dart';
import '../custom/custom_text_field.dart';
import '../database/sql_db.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'شادى');
  final _lastNameController = TextEditingController(text: 'ناصر');
  final _emailController = TextEditingController(text: 'test@gmail.com');
  final _passwordController = TextEditingController(text: '1234qwer');
  final _confirmPasswordController = TextEditingController(text: '1234qwer');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم إنشاء الحساب بنجاح!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // توجيه المستخدم بعد التسجيل
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ReportlyDashboard()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'فشل إنشاء الحساب'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primary,
              AppColors.primary.withAlpha(204),
              AppColors.primary.withAlpha(153),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                spacing: 8.h,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(39),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(25),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          spacing: 8.w,
                          children: [
                            Text(
                              'ريبورتلي',
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 32.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'أنشئ حسابك الآن',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withAlpha(230),
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(38),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(28.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          spacing: 12.h,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing: 10.w,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _firstNameController,
                                    label: 'الاسم الأول',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال الاسم الأول';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _lastNameController,
                                    label: 'اسم العائلة',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'يرجى إدخال اسم العائلة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            CustomTextField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني',
                              inputType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال بريدك الإلكتروني';
                                }
                                if (!value.contains('@')) {
                                  return 'يرجى إدخال بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              isPassword: true,
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            CustomTextField(
                              isPassword: true,
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'يرجى تأكيد كلمة المرور';
                                }
                                if (value != _passwordController.text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }
                                return null;
                              },
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return ElevatedButton(
                                  onPressed:
                                      // ************************* use sql signup function **************************************************************
                                      //     () => loginWithSqlDb(
                                      //       SqlDb(),
                                      //       _emailController,
                                      //       _passwordController,
                                      //       '${_firstNameController.text} ${_lastNameController.text}',
                                      //       context,
                                      //     ),
                                      // child: Text(
                                      //   'تسجيل الحساب',
                                      //   style: TextStyle(
                                      //     color: Colors.white,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                      // ************************* use api signup function **************************************************************
                                      authProvider.isLoading
                                      ? null
                                      : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 48.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    backgroundColor: authProvider.isLoading
                                        ? Colors.grey
                                        : AppColors.primary,
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'تسجيل الحساب',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                );
                              },
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'لديك حساب بالفعل؟ ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'تسجيل الدخول',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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

void loginWithSqlDb(
  SqlDb sqlDb,
  email,
  password,
  fullName,
  BuildContext context,
) {
  sqlDb
      .signUp(email: email.text, password: password.text, fullName: fullName)
      .then((result) {
        if (result['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ReportlyDashboard()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      });
}
