import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/auth_service.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/animated_button.dart';

/// Login Page with email/password authentication
class LoginPage
    extends
        StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<
    LoginPage
  >
  createState() => _LoginPageState();
}

class _LoginPageState
    extends
        State<
          LoginPage
        >
    with
        SingleTickerProviderStateMixin {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;

  late AnimationController _shakeController;
  late Animation<
    double
  >
  _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
    _shakeAnimation =
        Tween<
              double
            >(
              begin: 0,
              end: 1,
            )
            .animate(
              CurvedAnimation(
                parent: _shakeController,
                curve: Curves.elasticIn,
              ),
            );
    _loadRememberMe();
  }

  Future<
    void
  >
  _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final remembered =
        prefs.getBool(
          'rememberMe',
        ) ??
        false;
    if (remembered) {
      final savedEmail =
          prefs.getString(
            'savedEmail',
          ) ??
          '';
      final savedPassword =
          prefs.getString(
            'savedPassword',
          ) ??
          '';
      setState(
        () {
          _rememberMe = remembered;
          _emailController.text = savedEmail;
          _passwordController.text = savedPassword;
        },
      );
    }
  }

  Future<
    void
  >
  _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool(
        'rememberMe',
        true,
      );
      await prefs.setString(
        'savedEmail',
        _emailController.text,
      );
      await prefs.setString(
        'savedPassword',
        _passwordController.text,
      );
    } else {
      await prefs.remove(
        'rememberMe',
      );
      await prefs.remove(
        'savedEmail',
      );
      await prefs.remove(
        'savedPassword',
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _shakeError() {
    _shakeController.forward().then(
      (
        _,
      ) => _shakeController.reverse(),
    );
  }

  Future<
    void
  >
  _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      _shakeError();
      return;
    }

    setState(
      () {
        _isLoading = true;
        _errorMessage = null;
      },
    );

    try {
      // Save remember me preference
      await _saveRememberMe();

      // Call login API
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      context.go(
        AppRoutes.home,
      );
    } catch (
      e
    ) {
      setState(
        () {
          _errorMessage = e.toString().replaceAll(
            'Exception: ',
            '',
          );
        },
      );
      _shakeError();
    } finally {
      if (mounted) {
        setState(
          () => _isLoading = false,
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
                const SizedBox(
                  height: 40,
                ),
                // Header
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(
                            0.3,
                          ),
                          blurRadius: 20,
                          offset: const Offset(
                            0,
                            10,
                          ),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🛒',
                        style: TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Center(
                  child: Text(
                    'Welcome Back!',
                    style: AppTextStyles.displaySmall(),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: Text(
                    'Sign in to continue shopping smarter',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),

                // Error message
                if (_errorMessage !=
                    null)
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder:
                        (
                          context,
                          child,
                        ) {
                          return Transform.translate(
                            offset: Offset(
                              10 *
                                  _shakeAnimation.value *
                                  ((_shakeAnimation.value *
                                                      10)
                                                  .toInt() %
                                              2 ==
                                          0
                                      ? 1
                                      : -1),
                              0,
                            ),
                            child: child,
                          );
                        },
                    child: Container(
                      padding: const EdgeInsets.all(
                        16,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        border: Border.all(
                          color: AppColors.error.withOpacity(
                            0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodyMedium(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Email field
                Text(
                  'Email or Phone',
                  style: AppTextStyles.labelLarge(),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email or phone',
                    prefixIcon: const Icon(
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
                          return 'Please enter your email or phone';
                        }
                        return null;
                      },
                ),
                const SizedBox(
                  height: 20,
                ),

                // Password field
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
                    hintText: 'Enter your password',
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                ),
                const SizedBox(
                  height: 16,
                ),

                // Remember me & Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged:
                                (
                                  value,
                                ) => setState(
                                  () => _rememberMe =
                                      value ??
                                      false,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Remember me',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.labelMedium(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),

                // Login button
                AnimatedButton(
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                  gradient: AppColors.primaryGradient,
                  child: const Text(
                    'Sign In',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.borderLight,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Text(
                        'or continue with',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.borderLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      onTap: () {
                        // TODO: Implement Google sign in
                      },
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    _SocialLoginButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: () {
                        // TODO: Implement Apple sign in
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(
                        AppRoutes.signup,
                      ),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.primary,
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

class _SocialLoginButton
    extends
        StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.textPrimaryLight,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              label,
              style: AppTextStyles.labelMedium(),
            ),
          ],
        ),
      ),
    );
  }
}
