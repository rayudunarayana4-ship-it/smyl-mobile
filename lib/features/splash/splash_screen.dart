import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smyl_logo.dart';

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

    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
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
      backgroundColor: AppColors.obsidian,
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.electricCyan.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.auroraTeal.withOpacity(0.06),
              ),
            ),
          ),

          // Center Logo and Route Animation
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
                            '“Your Journey Can Carry More.”',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.champagneSand,
                              letterSpacing: 0.8,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Animated Global Route Trajectory Line
                    SizedBox(
                      width: 180,
                      height: 4,
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

          // Bottom subtle versioning
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'PREMIUM TRAVEL LOGISTICS PROTOCOL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate.withOpacity(0.6),
                  letterSpacing: 1.5,
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
    final bgPaint = Paint()
      ..color = AppColors.surfaceBorder
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), bgPaint);

    if (progress > 0) {
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.electricCyan, AppColors.auroraTeal],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final currentX = size.width * progress;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(currentX, size.height / 2),
        activePaint,
      );

      // Glowing tip
      canvas.drawCircle(
        Offset(currentX, size.height / 2),
        4.0,
        Paint()..color = AppColors.electricCyan,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashRouteLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
