import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';

/// Animated button with scale effect on tap
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isLoading;
  final bool isOutlined;
  final Gradient? gradient;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradient,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.animationFast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: AnimatedOpacity(
          duration: AppTheme.animationFast,
          opacity: isEnabled ? 1.0 : 0.5,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding:
                widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: widget.isOutlined
                  ? Colors.transparent
                  : (widget.gradient != null
                        ? null
                        : (widget.backgroundColor ?? AppColors.primary)),
              gradient: widget.isOutlined ? null : widget.gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.isOutlined
                  ? Border.all(
                      color: widget.backgroundColor ?? AppColors.primary,
                      width: 1.5,
                    )
                  : null,
              boxShadow: widget.isOutlined
                  ? null
                  : [
                      BoxShadow(
                        color: (widget.backgroundColor ?? AppColors.primary)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.foregroundColor ?? Colors.white,
                        ),
                      ),
                    )
                  : DefaultTextStyle(
                      style: TextStyle(
                        color: widget.isOutlined
                            ? (widget.backgroundColor ?? AppColors.primary)
                            : (widget.foregroundColor ?? Colors.white),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.child,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small icon button with animation
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.tooltip,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color ?? AppColors.textPrimaryLight,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}
