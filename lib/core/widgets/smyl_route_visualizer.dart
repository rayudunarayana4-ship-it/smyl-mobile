import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// ==============================================================================
/// SMYL GLOBAL — GLOBAL AURORA ROUTE VISUALIZER
/// ==============================================================================
class SmylRouteVisualizer extends StatefulWidget {
  final String originCode;
  final String originCity;
  final String destCode;
  final String destCity;
  final String? flightNumber;
  final double progress; // 0.0 to 1.0
  final bool isAnimated;

  const SmylRouteVisualizer({
    super.key,
    required this.originCode,
    required this.originCity,
    required this.destCode,
    required this.destCity,
    this.flightNumber,
    this.progress = 0.5,
    this.isAnimated = true,
  });

  @override
  State<SmylRouteVisualizer> createState() => _SmylRouteVisualizerState();
}

class _SmylRouteVisualizerState extends State<SmylRouteVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.isAnimated) {
      _animController.repeat();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Airport Codes & Cities Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.originCode.toUpperCase(),
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.warmIvory,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  widget.originCity,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (widget.flightNumber != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flight_takeoff_rounded,
                      size: 13,
                      color: AppColors.electricCyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.flightNumber!,
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.warmIvory,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.destCode.toUpperCase(),
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.electricCyan,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  widget.destCity,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Route Arch & Moving Waypoint Canvas
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return SizedBox(
              height: 48,
              width: double.infinity,
              child: CustomPaint(
                painter: _RouteCurvePainter(
                  progress: widget.progress,
                  pulseValue: _animController.value,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RouteCurvePainter extends CustomPainter {
  final double progress;
  final double pulseValue;

  _RouteCurvePainter({
    required this.progress,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(12, size.height - 8);
    final end = Offset(size.width - 12, size.height - 8);
    final controlPoint = Offset(size.width / 2, -12);

    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    // 1. Upcoming Route Baseline: subtle muted grey (#24303D)
    final basePaint = Paint()
      ..color = AppColors.surfaceBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(path, basePaint);

    // 2. Active / Completed Route: Aurora Teal to Aurora Cyan gradient
    final t = progress.clamp(0.0, 1.0);
    final currentX = (1 - t) * (1 - t) * start.dx +
        2 * (1 - t) * t * controlPoint.dx +
        t * t * end.dx;
    final currentY = (1 - t) * (1 - t) * start.dy +
        2 * (1 - t) * t * controlPoint.dy +
        t * t * end.dy;

    const steps = 30;
    final targetStep = (steps * t).round();
    if (targetStep > 0) {
      final activePaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.auroraTeal, AppColors.electricCyan],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;

      final progressPath = Path();
      progressPath.moveTo(start.dx, start.dy);
      for (int i = 1; i <= targetStep; i++) {
        final stepT = i / steps;
        final x = (1 - stepT) * (1 - stepT) * start.dx +
            2 * (1 - stepT) * stepT * controlPoint.dx +
            stepT * stepT * end.dx;
        final y = (1 - stepT) * (1 - stepT) * start.dy +
            2 * (1 - stepT) * stepT * controlPoint.dy +
            stepT * stepT * end.dy;
        progressPath.lineTo(x, y);
      }
      canvas.drawPath(progressPath, activePaint);
    }

    // Origin Node Pin (Aurora Teal)
    final originPaint = Paint()
      ..color = AppColors.auroraTeal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 4.0, originPaint);

    // Destination Node Pin (Aurora Cyan)
    final destPaint = Paint()
      ..color = AppColors.electricCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(end, 4.0, destPaint);

    // Current Moving Waypoint: Glowing ✦ Travel Point
    final currentPos = Offset(currentX, currentY);

    final pulseRadius = 6 + pulseValue * 10;
    canvas.drawCircle(
      currentPos,
      pulseRadius,
      Paint()
        ..color = AppColors.electricCyan.withOpacity(0.35 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Solid core pin
    canvas.drawCircle(
      currentPos,
      4.5,
      Paint()..color = AppColors.warmIvory,
    );
    canvas.drawCircle(
      currentPos,
      2.5,
      Paint()..color = AppColors.electricCyan,
    );
  }

  @override
  bool shouldRepaint(covariant _RouteCurvePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pulseValue != pulseValue;
}
