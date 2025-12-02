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
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(DioException e) {
    // Check for specific error responses from backend
    if (e.response != null) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] ?? data['error'] : null;
      
      switch (e.response?.statusCode) {
        case 409:
          if (message != null) return message.toString();
          return 'البريد الإلكتروني مسجل بالفعل. يرجى استخدام بريد آخر أو تسجيل الدخول';
        case 400:
          if (message != null) return message.toString();
          return 'بيانات غير صحيحة. تأكد من جميع المدخلات';
        case 422:
          if (message != null) return message.toString();
          return 'البيانات المدخلة غير صحيحة';
        case 500:
          return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
        default:
          return message?.toString() ?? 'فشل إنشاء الحساب';
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

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        setState(() {
          _errorMessage = 'يجب الموافقة على الشروط والأحكام';
        });
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'كلمات المرور غير متطابقة';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await _authService.signup(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            // Navigate to home on success (or login)
            Navigator.pushReplacementNamed(context, 'home');
          } else {
            setState(() {
              _errorMessage = response.data['message'] ?? 'فشل إنشاء الحساب';
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
                // Name Field
                CustomTextField(
                  controller: _nameController,
                  hintText: 'الاسم الكامل',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    if (value.length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
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
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Confirm Password Field
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'تأكيد كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !_showConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء تأكيد كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Terms and Conditions Checkbox
                CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                  title: Text(
                    'أوافق على الشروط والأحكام',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  checkColor: Colors.white,
                  activeColor: AppTheme.accentColor,
                ),
                const SizedBox(height: 20),
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
