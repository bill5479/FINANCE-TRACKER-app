import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/theme/app_theme.dart';

/// Premium Liquid Glass button.
class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isExpanded;
  final List<Color>? gradientColors;
  final double? borderRadius;
  final bool small;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isExpanded = false,
    this.gradientColors,
    this.borderRadius,
    this.small = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: GlassTokens.animFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final hasGradient = widget.gradientColors != null;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: LiquidGlass(
          settings: LiquidGlassSettings(
            blur: GlassTokens.blurMedium,
            ambientStrength: GlassTokens.ambientMedium,
            lightAngle: 0.3 * math.pi,
            glassColor: hasGradient
                ? widget.gradientColors!.first.withOpacity(0.3)
                : (isDark ? Colors.white12 : Colors.black12),
            thickness: GlassTokens.thicknessLight,
          ),
          shape: LiquidRoundedSuperellipse(
            borderRadius: Radius.circular(
                widget.borderRadius ?? GlassTokens.radiusFull),
          ),
          glassContainsChild: false,
          child: Container(
            width: widget.isExpanded ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.small ? 16 : 24,
              vertical: widget.small ? 10 : 14,
            ),
            child: Row(
              mainAxisSize:
                  widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: hasGradient
                        ? widget.gradientColors!.first
                        : (isDark ? Colors.white : AppTheme.lightAccent),
                    size: widget.small ? 18 : 22,
                  ),
                  SizedBox(width: GlassTokens.spacingSM),
                ],
                Text(
                  widget.label,
                  style: (widget.small
                          ? AppTheme.bodySmall
                          : AppTheme.titleMedium)
                      .copyWith(
                    color: hasGradient
                        ? widget.gradientColors!.first
                        : (isDark ? Colors.white : AppTheme.lightTextPrimary),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

