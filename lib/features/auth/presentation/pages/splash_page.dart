import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';

/// Animated Splash Screen
class SplashPage
    extends
        StatefulWidget {
  const SplashPage({
    super.key,
  });

  @override
  State<
    SplashPage
  >
  createState() => _SplashPageState();
}

class _SplashPageState
    extends
        State<
          SplashPage
        >
    with
        TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<
    double
  >
  _logoFadeAnimation;
  late Animation<
    double
  >
  _logoScaleAnimation;
  late Animation<
    double
  >
  _textFadeAnimation;
  late Animation<
    double
  >
  _taglineAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateAfterSplash();
  }

  void _initAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );

    _logoFadeAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _logoController,
                curve: const Interval(
                  0.0,
                  0.6,
                  curve: Curves.easeOut,
                ),
              ),
            );

    _logoScaleAnimation =
        Tween<
              double
            >(
              begin: 0.5,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _logoController,
                curve: const Interval(
                  0.0,
                  0.6,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _textFadeAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(
                  0.0,
                  0.5,
                  curve: Curves.easeOut,
                ),
              ),
            );

    _taglineAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(
                  0.4,
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            );

    // Start animations
    _logoController.forward().then(
      (
        _,
      ) {
        _textController.forward();
      },
    );
  }

  Future<
    void
  >
  _navigateAfterSplash() async {
    await Future.delayed(
      Duration(
        milliseconds: AppConstants.splashDuration,
      ),
    );

    if (!mounted) return;

    // Check if user has valid token
    final hasToken = await ApiClient.hasToken();

    if (!mounted) return;

    if (hasToken) {
      context.go(
        AppRoutes.home,
      );
    } else {
      context.go(
        AppRoutes.login,
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              Color(
                0xFF1E3A8A,
              ), // Blue 900
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder:
                    (
                      context,
                      child,
                    ) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: child,
                        ),
                      );
                    },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      30,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.2,
                        ),
                        blurRadius: 30,
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
                        fontSize: 60,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              // App Name
              AnimatedBuilder(
                animation: _textController,
                builder:
                    (
                      context,
                      child,
                    ) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            20 *
                                (1 -
                                    _textFadeAnimation.value),
                          ),
                          child: child,
                        ),
                      );
                    },
                child: Text(
                  AppConstants.appName,
                  style: AppTextStyles.displayLarge(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              // Tagline
              AnimatedBuilder(
                animation: _textController,
                builder:
                    (
                      context,
                      child,
                    ) {
                      return Opacity(
                        opacity: _taglineAnimation.value,
                        child: child,
                      );
                    },
                child: Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.bodyLarge(
                    color: Colors.white.withOpacity(
                      0.8,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Loading indicator
              AnimatedBuilder(
                animation: _textController,
                builder:
                    (
                      context,
                      child,
                    ) {
                      return Opacity(
                        opacity: _taglineAnimation.value,
                        child: child,
                      );
                    },
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<
                          Color
                        >(
                          Colors.white,
                        ),
                  ),
                ),
              ),
              const SizedBox(
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
