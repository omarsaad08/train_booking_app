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
  String? _errorMessage;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(DioException e) {
    // Check for specific error responses from backend
    if (e.response != null) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] ?? data['error'] : null;

      switch (e.response?.statusCode) {
        case 401:
          if (message != null) return message.toString();
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        case 404:
          return 'الحساب غير موجود. يرجى التحقق من البريد الإلكتروني';
        case 400:
          if (message != null) return message.toString();
          return 'بيانات غير صحيحة. يرجى التحقق من المدخلات';
        case 500:
          return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
        default:
          return message?.toString() ?? 'فشل تسجيل الدخول';
      }
    }

    // Network errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استقبال البيانات. حاول مجددا';
      case DioExceptionType.badResponse:
        return 'حدث خطأ في الاتصال. يرجى المحاولة لاحقاً';
      case DioExceptionType.unknown:
        return 'خطأ في الاتصال. تحقق من اتصالك بالإنترنت';
      default:
        return 'خطأ غير متوقع. يرجى المحاولة لاحقاً';
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          if (response.statusCode == 200) {
            // Navigate to home on success
            Navigator.pushReplacementNamed(context, 'home');
          } else {
            setState(() {
              _errorMessage = response.data['message'] ?? 'فشل تسجيل الدخول';
            });
          }
        }
      } on DioException catch (e) {
        if (mounted) {
          final errorMsg = _getErrorMessage(e);
          setState(() {
            _errorMessage = errorMsg;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'حدث خطأ غير متوقع. يرجى المحاولة لاحقاً';
          });
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
                    child: Icon(Icons.train, size: 80, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
                // Main Title
                Text(
                  'مرحباً بك مجدداً',
                  textAlign: TextAlign.center,
                  style: AppTheme.headline1.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'سجل الدخول لحجز رحلتك القادمة',
                  textAlign: TextAlign.center,
                  style: AppTheme.subtitle2.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                // Error Message Display
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      border: Border.all(color: AppTheme.errorColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppTheme.errorColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 20),
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
                    if (!value.contains('@')) {
                      return 'يرجى إدخال بريد إلكتروني صحيح';
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
                  obscureText: !_showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
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
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.textSecondary,
                      ),
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
