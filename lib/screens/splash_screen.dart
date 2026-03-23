import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:fintracker_app/theme/app_theme.dart';
import 'package:fintracker_app/theme/glass_tokens.dart';
import 'package:fintracker_app/screens/home_screen.dart';

/// Premium animated splash screen with Liquid Glass effects.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _orbController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _progressOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    // Logo animation
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text animation
    _textController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Orb background
    _orbController = AnimationController(
      duration: Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // Start animation sequence
    Future.delayed(Duration(milliseconds: 300), () {
      _logoController.forward();
    });
    Future.delayed(Duration(milliseconds: 900), () {
      _textController.forward();
    });

    // Navigate after splash
    Future.delayed(Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: Duration(milliseconds: 600),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E27),
      body: AnimatedBuilder(
        animation: _orbController,
        builder: (context, _) {
          return Stack(
            children: [
              // Floating gradient orbs
              ...List.generate(6, (i) {
                final phase = i * 0.167;
                final value = _orbController.value;
                final x =
                    0.2 + 0.6 * math.sin((value + phase) * 2 * math.pi);
                final y =
                    0.1 + 0.8 * math.cos((value + phase * 1.5) * 2 * math.pi);
                final size = 100.0 + i * 50.0;
                final colors = [
                  [Color(0xFF6C63FF), Color(0xFF00D9FF)],
                  [Color(0xFF00E5A0), Color(0xFF00D9FF)],
                  [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
                  [Color(0xFFFFB547), Color(0xFFFF6B6B)],
                  [Color(0xFF00D9FF), Color(0xFF6C63FF)],
                  [Color(0xFFE040FB), Color(0xFF6C63FF)],
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
                          colors[0].withOpacity(0.2),
                          colors[1].withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // Main content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, _) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF00D9FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6C63FF).withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: GlassTokens.spacingXL),
                    // App name
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Text(
                          'FinTracker',
                          style: AppTheme.displayLarge.copyWith(
                            color: Colors.white,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: GlassTokens.spacingSM),
                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: Text(
                        'Your finances, beautifully organized',
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white60,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: GlassTokens.spacingXXL),
                    // Loading indicator
                    FadeTransition(
                      opacity: _progressOpacity,
                      child: SizedBox(
                        width: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF6C63FF),
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


