import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MobileDeviceFrame extends StatelessWidget {
  final Widget child;

  const MobileDeviceFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If already on mobile screen dimensions (width <= 520), render edge-to-edge
        if (constraints.maxWidth <= 520) {
          return child;
        }

        // On desktop or widescreen browsers, frame the app inside a luxury phone bezel
        return Container(
          color: const Color(0xFF06070A),
          child: Center(
            child: Container(
              width: 393,
              height: 852,
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                borderRadius: BorderRadius.circular(52),
                border: Border.all(
                  color: const Color(0xFF2A364F),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricCyan.withOpacity(0.08),
                    blurRadius: 40,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.85),
                    blurRadius: 50,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(48),
                child: Stack(
                  children: [
                    // The Mobile Screen App Content
                    Positioned.fill(child: child),

                    // Phone Top Notch / Dynamic Island simulation
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1E2638),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0F1522),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.electricCyan.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Phone Bottom Home Indicator Bar
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 135,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: AppColors.slate.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
