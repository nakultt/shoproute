import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth_service.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../core/widgets/animated_button.dart';

/// Sign Up Page with form validation and password strength
class SignupPage
    extends
        StatefulWidget {
  const SignupPage({
    super.key,
  });

  @override
  State<
    SignupPage
  >
  createState() => _SignupPageState();
}

class _SignupPageState
    extends
        State<
          SignupPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _passwordStrength = 0; // 0: none, 1: weak, 2: medium, 3: strong

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(
      _updatePasswordStrength,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;

    if (password.length >=
        8) {
      strength++;
    }
    if (password.contains(
          RegExp(
            r'[A-Z]',
          ),
        ) &&
        password.contains(
          RegExp(
            r'[a-z]',
          ),
        )) {
      strength++;
    }
    if (password.contains(
          RegExp(
            r'[0-9]',
          ),
        ) &&
        password.contains(
          RegExp(
            r'[!@#$%^&*(),.?":{}|<>]',
          ),
        )) {
      strength++;
    }

    setState(
      () => _passwordStrength = strength,
    );
  }

  Future<
    void
  >
  _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(
      () => _isLoading = true,
    );

    try {
      // Call signup API
      await _authService.register(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.go(
        AppRoutes.verifyEmail,
        extra: _emailController.text,
      );
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Signup failed: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.success;
      default:
        return AppColors.borderLight;
    }
  }

  String _getStrengthText() {
    switch (_passwordStrength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Medium';
      case 3:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(
            AppRoutes.login,
          ),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: AppTextStyles.displaySmall(),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Sign up to start shopping smarter',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),

                // Full Name
                Text(
                  'Full Name',
                  style: AppTextStyles.labelLarge(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                  validator:
                      (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.length <
                            2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                ),
                const SizedBox(
                  height: 20,
                ),

                // Email
                Text(
                  'Email',
                  style: AppTextStyles.labelLarge(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                  validator:
                      (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(
                          value,
                        )) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                ),
                const SizedBox(
                  height: 20,
                ),

                // Phone
                Text(
                  'Phone Number',
                  style: AppTextStyles.labelLarge(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.textTertiaryLight,
                    ),
                    prefixText: '+91 ',
                  ),
                  validator:
                      (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length <
                            10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                ),
                const SizedBox(
                  height: 20,
                ),

                // Password
                Text(
                  'Password',
                  style: AppTextStyles.labelLarge(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textTertiaryLight,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                  validator:
                      (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length <
                            AppConstants.minPasswordLength) {
                          return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                        }
                        return null;
                      },
                ),
                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                _passwordStrength >=
                                    1
                                ? _getStrengthColor()
                                : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(
                              2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                _passwordStrength >=
                                    2
                                ? _getStrengthColor()
                                : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(
                              2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                _passwordStrength >=
                                    3
                                ? _getStrengthColor()
                                : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(
                              2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Text(
                        _getStrengthText(),
                        style: AppTextStyles.labelSmall(
                          color: _getStrengthColor(),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(
                  height: 20,
                ),

                // Confirm Password
                Text(
                  'Confirm Password',
                  style: AppTextStyles.labelLarge(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textTertiaryLight,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                  validator:
                      (
                        value,
                      ) {
                        if (value ==
                                null ||
                            value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value !=
                            _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                ),
                const SizedBox(
                  height: 32,
                ),

                // Sign up button
                AnimatedButton(
                  onPressed: _handleSignup,
                  isLoading: _isLoading,
                  gradient: AppColors.primaryGradient,
                  child: const Text(
                    'Create Account',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(
                        AppRoutes.login,
                      ),
                      child: Text(
                        'Log In',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
