import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/animations.dart';

/// Neon Button with gradient and animations
class NeonButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final NeonButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;

  const NeonButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.variant = NeonButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppAnimations.fast),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.variant) {
      case NeonButtonVariant.primary:
        return AppColors.accentPrimary;
      case NeonButtonVariant.secondary:
        return AppColors.secondaryPrimary;
      case NeonButtonVariant.outline:
        return Colors.transparent;
      case NeonButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.variant) {
      case NeonButtonVariant.primary:
      case NeonButtonVariant.secondary:
        return AppColors.textInverse;
      case NeonButtonVariant.outline:
      case NeonButtonVariant.ghost:
        return AppColors.accentPrimary;
    }
  }

  BoxBorder? _getBorder() {
    if (widget.variant == NeonButtonVariant.outline) {
      return Border.all(
        color: AppColors.accentPrimary,
        width: 2,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.isDisabled || widget.isLoading;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: isDisabled ? null : (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: isDisabled ? null : () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: AppAnimations.fast),
        width: widget.width,
        height: widget.height ?? 48,
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.backgroundTertiary
              : _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: _getBorder(),
          boxShadow: _isPressed || isDisabled
              ? []
              : [
                  BoxShadow(
                    color: _getBackgroundColor().withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTextColor(),
                      ),
                    ),
                  )
                : DefaultTextStyle(
                    style: AppTypography.button.copyWith(
                      color: isDisabled
                          ? AppColors.textTertiary
                          : _getTextColor(),
                    ),
                    child: widget.child,
                  ),
          ),
        ),
      )
          .animate(
            target: _isPressed ? 1 : 0,
          )
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.95, 0.95),
            duration: const Duration(milliseconds: AppAnimations.fast),
          ),
    );
  }
}

enum NeonButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}
