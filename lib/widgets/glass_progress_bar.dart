import 'package:flutter/material.dart';
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';

/// Animated glassmorphic budget progress bar.
class GlassProgressBar extends StatelessWidget {
  final double progress;
  final String label;
  final String? sublabel;
  final List<Color>? gradientColors;
  final double height;
  final bool showPercentage;

  const GlassProgressBar({
    super.key,
    required this.progress,
    required this.label,
    this.sublabel,
    this.gradientColors,
    this.height = 10,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final colors = gradientColors ??
        (progress >= 1.0
            ? [AppTheme.darkError, AppTheme.darkWarning]
            : progress >= 0.8
                ? [AppTheme.darkWarning, Color(0xFFFFD93D)]
                : AppTheme.accentGradient);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (sublabel != null)
              Text(
                sublabel!,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary(context),
                ),
              ),
            if (showPercentage)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTheme.labelLarge.copyWith(
                    color: progress >= 1.0
                        ? AppTheme.error(context)
                        : AppTheme.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: GlassTokens.spacingSM),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height),
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height),
            child: AnimatedFractionallySizedBox(
              duration: GlassTokens.animSlow,
              curve: Curves.easeOutCubic,
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height),
                  gradient: LinearGradient(colors: colors),
                  boxShadow: [
                    BoxShadow(
                      color: colors.first.withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated fractionally sized box for progress bars.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Alignment alignment;
  final Widget? child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    required this.widthFactor,
    required this.alignment,
    this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}

