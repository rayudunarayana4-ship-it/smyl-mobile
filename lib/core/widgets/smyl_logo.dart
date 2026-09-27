import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SmylLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final Color? color;

  const SmylLogo({
    super.key,
    this.size = 40.0,
    this.showText = false,
    this.showTagline = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoSymbol = CustomPaint(
      size: Size(size, size),
      painter: _SmylSymbolPainter(
        primaryColor: color ?? AppColors.electricCyan,
        secondaryColor: AppColors.auroraTeal,
      ),
    );

    if (!showText) {
      return logoSymbol;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            logoSymbol,
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SMYL',
                      style: TextStyle(
                        fontSize: size * 0.55,
                        fontWeight: FontWeight.w900,
                        color: AppColors.warmIvory,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'GLOBAL',
                      style: TextStyle(
                        fontSize: size * 0.42,
                        fontWeight: FontWeight.w400,
                        color: AppColors.electricCyan,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
                if (showTagline)
                  Text(
                    'Your Journey Can Carry More.',
                    style: TextStyle(
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.champagneSand,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SmylSymbolPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _SmylSymbolPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    // Glowing outer dynamic flight orbit
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          primaryColor.withOpacity(0.0),
          primaryColor,
          secondaryColor,
          primaryColor.withOpacity(0.0),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
        transform: const GradientRotation(math.pi * 0.35),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Outer trajectory arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 1.5, false, orbitPaint);

    // Inner reverse orbit representing bidirectional carry
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..color = secondaryColor.withOpacity(0.9);

    final innerRect = Rect.fromCircle(center: center, radius: radius * 0.62);
    canvas.drawArc(innerRect, math.pi * 0.35, math.pi * 1.3, false, innerPaint);

    // Central Global Connection Node
    final nodeGlowPaint = Paint()
      ..color = primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.22, nodeGlowPaint);

    final nodePaint = Paint()
      ..color = AppColors.warmIvory
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.11, nodePaint);

    // Orbital transit waypoint dot
    final waypointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final wayPointAngle = -math.pi * 0.75;
    final wayPoint = Offset(
      center.dx + radius * math.cos(wayPointAngle),
      center.dy + radius * math.sin(wayPointAngle),
    );
    canvas.drawCircle(wayPoint, size.width * 0.08, waypointPaint);
  }

  @override
  bool shouldRepaint(covariant _SmylSymbolPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
