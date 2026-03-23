import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fintracker_app/theme/app_theme.dart';

/// Animated gradient background with floating glass orbs.
class AnimatedGradientBg extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBg({super.key, required this.child});

  @override
  State<AnimatedGradientBg> createState() => _AnimatedGradientBgState();
}

class _AnimatedGradientBgState extends State<AnimatedGradientBg>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Color(0xFF0A0E27),
                          Color(0xFF0F1B3D),
                          Color(0xFF0A1628),
                        ]
                      : [
                          Color(0xFFF0F2FF),
                          Color(0xFFE8ECFF),
                          Color(0xFFF5F0FF),
                        ],
                ),
              ),
            ),
            // Floating orbs
            ...List.generate(5, (i) {
              final phase = i * 0.2;
              final value = _controller.value;
              final x = 0.2 + 0.6 * math.sin((value + phase) * 2 * math.pi);
              final y = 0.15 + 0.7 * math.cos((value + phase * 1.3) * 2 * math.pi);
              final size = 120.0 + i * 40.0;

              final colors = isDark
                  ? [
                      [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                      [Color(0xFF00E5A0), Color(0xFF00D9FF)],
                      [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
                      [Color(0xFFFFB547), Color(0xFFFF6B6B)],
                      [Color(0xFF00D9FF), Color(0xFF6C63FF)],
                    ][i]
                  : [
                      [Color(0xFF6C63FF).withOpacity(0.15), Color(0xFF00D9FF).withOpacity(0.1)],
                      [Color(0xFF00E5A0).withOpacity(0.12), Color(0xFF00D9FF).withOpacity(0.1)],
                      [Color(0xFFFF6B6B).withOpacity(0.1), Color(0xFF6C63FF).withOpacity(0.08)],
                      [Color(0xFFFFB547).withOpacity(0.1), Color(0xFFFF6B6B).withOpacity(0.08)],
                      [Color(0xFF00D9FF).withOpacity(0.12), Color(0xFF6C63FF).withOpacity(0.1)],
                    ][i];

              return Positioned(
                left: MediaQuery.of(context).size.width * x - size / 2,
                top: MediaQuery.of(context).size.height * y - size / 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors[0].withOpacity(isDark ? 0.15 : 0.25),
                        colors[1].withOpacity(0),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Content
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

