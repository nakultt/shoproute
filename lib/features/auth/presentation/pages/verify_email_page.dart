import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/routes/app_router.dart';
import '../../../../core/widgets/animated_button.dart';

/// Email verification page with OTP input
class VerifyEmailPage
    extends
        StatefulWidget {
  final String email;

  const VerifyEmailPage({
    super.key,
    required this.email,
  });

  @override
  State<
    VerifyEmailPage
  >
  createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState
    extends
        State<
          VerifyEmailPage
        > {
  final List<
    TextEditingController
  >
  _controllers = List.generate(
    6,
    (
      _,
    ) => TextEditingController(),
  );
  final List<
    FocusNode
  >
  _focusNodes = List.generate(
    6,
    (
      _,
    ) => FocusNode(),
  );

  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(
      () {
        _canResend = false;
        _resendTimer = 60;
      },
    );

    _timer = Timer.periodic(
      const Duration(
        seconds: 1,
      ),
      (
        timer,
      ) {
        if (_resendTimer >
            0) {
          setState(
            () => _resendTimer--,
          );
        } else {
          setState(
            () => _canResend = true,
          );
          timer.cancel();
        }
      },
    );
  }

  String get _otp => _controllers
      .map(
        (
          c,
        ) => c.text,
      )
      .join();

  Future<
    void
  >
  _verifyOtp() async {
    if (_otp.length !=
        6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the complete OTP',
          ),
        ),
      );
      return;
    }

    setState(
      () => _isLoading = true,
    );

    try {
      // TODO: Implement actual OTP verification API call
      await Future.delayed(
        const Duration(
          seconds: 2,
        ),
      );

      if (!mounted) return;
      context.go(
        AppRoutes.home,
      );
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Verification failed: ${e.toString()}',
          ),
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

  Future<
    void
  >
  _resendOtp() async {
    if (!_canResend) return;

    try {
      // TODO: Implement actual resend OTP API call
      await Future.delayed(
        const Duration(
          seconds: 1,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP sent successfully!',
          ),
        ),
      );
      _startResendTimer();
    } catch (
      e
    ) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to resend OTP: ${e.toString()}',
          ),
        ),
      );
    }
  }

  void _onOtpChanged(
    String value,
    int index,
  ) {
    if (value.length ==
            1 &&
        index <
            5) {
      _focusNodes[index +
              1]
          .requestFocus();
    } else if (value.isEmpty &&
        index >
            0) {
      _focusNodes[index -
              1]
          .requestFocus();
    }

    // Auto-verify when all digits are entered
    if (_otp.length ==
        6) {
      _verifyOtp();
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
            AppRoutes.signup,
          ),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              // Email icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                height: 32,
              ),
              Text(
                'Verify Your Email',
                style: AppTextStyles.displaySmall(),
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                'We sent a verification code to',
                style: AppTextStyles.bodyMedium(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                widget.email,
                style: AppTextStyles.bodyLarge(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(
                height: 40,
              ),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (
                    index,
                  ) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: _controllers[index].text.isNotEmpty
                              ? AppColors.primarySurface
                              : AppColors.surfaceLight,
                        ),
                        style: AppTextStyles.headlineLarge(),
                        onChanged:
                            (
                              value,
                            ) => _onOtpChanged(
                              value,
                              index,
                            ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 32,
              ),

              // Verify button
              AnimatedButton(
                onPressed: _verifyOtp,
                isLoading: _isLoading,
                gradient: AppColors.primaryGradient,
                child: const Text(
                  'Verify Email',
                ),
              ),
              const SizedBox(
                height: 24,
              ),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend
                        ? _resendOtp
                        : null,
                    child: Text(
                      _canResend
                          ? 'Resend'
                          : 'Resend in ${_resendTimer}s',
                      style: AppTextStyles.labelLarge(
                        color: _canResend
                            ? AppColors.primary
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
