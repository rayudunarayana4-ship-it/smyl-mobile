import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smyl_button.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/app_repository.dart';

/// ==============================================================================
/// SMYL GLOBAL — GLOBAL AURORA ONBOARDING SCREEN
/// ==============================================================================
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _screens = const [
    _OnboardingData(
      headline: 'SEND SMARTER',
      explanation: 'Connect with verified travellers heading your way.',
      buttonText: 'SEND AN ITEM →',
      icon: Icons.outbox_rounded,
      accentColor: AppColors.electricCyan,
      targetRole: UserRole.sender,
    ),
    _OnboardingData(
      headline: 'TRAVEL & CARRY',
      explanation: 'Use your available luggage space on your journey.',
      buttonText: 'TRAVEL & CARRY →',
      icon: Icons.luggage_rounded,
      accentColor: AppColors.auroraTeal,
      targetRole: UserRole.traveller,
    ),
    _OnboardingData(
      headline: 'GLOBAL ESCROW',
      explanation: 'Every handover is verified with cryptographic OTP codes.',
      buttonText: 'ENTER SMYL GLOBAL',
      icon: Icons.verified_user_rounded,
      accentColor: AppColors.champagneSand,
      targetRole: UserRole.both,
    ),
  ];

  void _onActionButtonPressed(int index) {
    final role = _screens[index].targetRole;
    ref.read(appRepositoryProvider).switchUserRole(role);

    if (index < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.mainShell);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian, // #070A0F
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go(AppRoutes.mainShell),
            child: Text(
              'SKIP',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _screens.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final data = _screens[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        // Signature Circular Artwork with subtle Aurora Glow
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceCard, // #111923
                            border: Border.all(
                              color: data.accentColor.withOpacity(0.35),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: data.accentColor.withOpacity(0.12),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surfaceBorder,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              Icon(
                                data.icon,
                                size: 68,
                                color: data.accentColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Headline
                        Text(
                          data.headline,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayLarge.copyWith(
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Short Explanation
                        Text(
                          data.explanation,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 16,
                            color: AppColors.slateLight,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots & Single Distinct CTA
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _screens.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.electricCyan
                              : AppColors.surfaceBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SmylButton(
                    text: _screens[_currentIndex].buttonText,
                    onPressed: () => _onActionButtonPressed(_currentIndex),
                    variant: SmylButtonVariant.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String headline;
  final String explanation;
  final String buttonText;
  final IconData icon;
  final Color accentColor;
  final UserRole targetRole;

  const _OnboardingData({
    required this.headline,
    required this.explanation,
    required this.buttonText,
    required this.icon,
    required this.accentColor,
    required this.targetRole,
  });
}
