import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smyl_logo.dart';

/// ==============================================================================
/// SMYL GLOBAL — GLOBAL AURORA SPLASH SCREEN
/// ==============================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _routeProgressAnimation;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.8, curve: Curves.easeIn),
      ),
    );

    _routeProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();

    _transitionTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian, // #070A0F
      body: Stack(
        children: [
          // Background subtle atmospheric Aurora glow
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricCyan.withOpacity(0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.auroraTeal.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center Logo, Brand Headline & Route Animation
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Logo Symbol
                    Opacity(
                      opacity: _logoOpacityAnimation.value,
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: const SmylLogo(size: 88),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Brand Typography
                    Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'SMYL',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.warmIvory,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'GLOBAL',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.electricCyan,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Move smarter with every journey.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.slateLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Elegant Global Route Animation
                    SizedBox(
                      width: 200,
                      height: 24,
                      child: CustomPaint(
                        painter: _SplashRouteLinePainter(
                          progress: _routeProgressAnimation.value,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom subtle protocol badge
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'GLOBAL AURORA PROTOCOL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate.withOpacity(0.5),
                  letterSpacing: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashRouteLinePainter extends CustomPainter {
  final double progress;

  _SplashRouteLinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final startY = size.height / 2;
    final bgPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, startY), Offset(size.width, startY), bgPaint);

    // Origin node
    canvas.drawCircle(
      Offset(0, startY),
      3.0,
      Paint()..color = AppColors.auroraTeal,
    );

    // Destination node
    canvas.drawCircle(
      Offset(size.width, startY),
      3.0,
      Paint()..color = AppColors.electricCyan,
    );

    if (progress > 0) {
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.auroraTeal, AppColors.electricCyan],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      final currentX = size.width * progress;
      canvas.drawLine(
        Offset(0, startY),
        Offset(currentX, startY),
        activePaint,
      );

      // Glowing tip
      canvas.drawCircle(
        Offset(currentX, startY),
        5.0,
        Paint()
          ..color = AppColors.electricCyan.withOpacity(0.4)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(currentX, startY),
        2.5,
        Paint()..color = AppColors.warmIvory,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashRouteLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
