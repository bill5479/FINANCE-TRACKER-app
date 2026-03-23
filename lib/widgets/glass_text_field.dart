import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/theme/app_theme.dart';

/// Frosted glass text input field.
class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return LiquidGlass(
      settings: LiquidGlassSettings(
        blur: GlassTokens.blurLight,
        ambientStrength: GlassTokens.ambientStrong,
        lightAngle: 0.4 * math.pi,
        glassColor: isDark ? Colors.black12 : Colors.white70,
        thickness: GlassTokens.thicknessHeavy,
      ),
      shape: LiquidRoundedSuperellipse(
        borderRadius: Radius.circular(GlassTokens.radiusMedium),
      ),
      glassContainsChild: false,
      child: Padding(
        padding: EdgeInsets.only(left: 4),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textTertiary(context),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppTheme.textTertiary(context),
                    size: 22,
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(
              vertical: 14,
              horizontal: prefixIcon != null ? 0 : 16,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

