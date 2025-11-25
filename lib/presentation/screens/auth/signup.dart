import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:train_booking/data/auth_service.dart';
import 'package:train_booking/presentation/components/custom_button.dart';
import 'package:train_booking/presentation/components/custom_text_field.dart';
import 'package:train_booking/config/app_theme.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.signup(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            // Navigate to home on success (or login)
            Navigator.pushReplacementNamed(context, 'home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل إنشاء الحساب: ${response.statusMessage}'),
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
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Main Title
                Text(
                  'إنشاء حساب جديد',
                  textAlign: TextAlign.center,
                  style: AppTheme.headline1.copyWith(color: AppTheme.accentColor),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'انضم إلينا وابدأ رحلتك',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitle2.copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  hintText: 'الاسم الكامل',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Sign Up Button with Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomButton(
                    text: 'إنشاء حساب',
                    onPressed: _signup,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 24),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟',
                      style: AppTheme.body2.copyWith(color: AppTheme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'تسجيل الدخول',
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
