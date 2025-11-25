import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:train_booking/data/auth_service.dart';
import 'package:train_booking/config/app_theme.dart';
import 'package:train_booking/presentation/components/custom_button.dart';
import 'package:train_booking/presentation/components/custom_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          if (response.statusCode == 200) {
            // Navigate to home on success
            Navigator.pushReplacementNamed(context, 'home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل تسجيل الدخول: ${response.statusMessage}'),
              ),
            );
          }
        }
      } on DioException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الاتصال: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('حدث خطأ غير متوقع')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Gradient Logo Container
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.train,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Main Title
                Text(
                  'مرحباً بك مجدداً',
                  textAlign: TextAlign.center,
                  style: AppTheme.headline1.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'سجل الدخول لحجز رحلتك القادمة',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitle2.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                // Email Field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'البريد الإلكتروني',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Login Button with Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomButton(
                    text: 'تسجيل الدخول',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 24),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: AppTheme.body2.copyWith(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'signup');
                      },
                      child: Text(
                        'إنشاء حساب',
                        style: AppTheme.body1.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
