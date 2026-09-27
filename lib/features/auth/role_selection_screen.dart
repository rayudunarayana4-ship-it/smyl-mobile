import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/smyl_button.dart';
import '../../core/widgets/smyl_card.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/app_repository.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.both;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  'STEP 1 OF 3 • PROFILE INTENT',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'What brings you\nto SMYL?',
                style: AppTypography.displayLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Select your primary operating mode. You can switch or combine roles anytime in your settings.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 32),

              // Role Cards
              _buildRoleOption(
                role: UserRole.sender,
                title: 'I WANT TO SEND',
                subtitle: 'I need to move an item.',
                detail:
                    'Ship documents, apparel, and permitted items with verified international travellers flying direct routes.',
                icon: Icons.outbox_rounded,
                accentColor: AppColors.electricCyan,
              ),
              const SizedBox(height: 14),

              _buildRoleOption(
                role: UserRole.traveller,
                title: 'I\'M TRAVELLING',
                subtitle: 'I have available carrying capacity.',
                detail:
                    'Monetize unused luggage allowance on your domestic or international flights by carrying verified cargo.',
                icon: Icons.flight_takeoff_rounded,
                accentColor: AppColors.auroraTeal,
              ),
              const SizedBox(height: 14),

              _buildRoleOption(
                role: UserRole.both,
                title: 'I DO BOTH',
                subtitle: 'Send items and travel.',
                detail:
                    'Unified experience for active global citizens who both dispatch consignments and travel internationally.',
                icon: Icons.all_inclusive_rounded,
                accentColor: AppColors.champagneSand,
              ),

              const Spacer(),

              // Continue Button
              SmylButton(
                text: 'Continue as ${_getRoleTitle(_selectedRole)}',
                onPressed: () {
                  ref.read(appRepositoryProvider).switchUserRole(_selectedRole);
                  context.go(AppRoutes.login);
                },
                variant: SmylButtonVariant.primary,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedRole == role;

    return SmylCard(
      isHighlighted: isSelected,
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withOpacity(0.18)
                  : AppColors.deepSpace,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor : AppColors.surfaceBorder,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? accentColor : AppColors.slateLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelUppercase.copyWith(
                        color: isSelected ? accentColor : AppColors.warmIvory,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.obsidian,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.warmIvory,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slate,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.sender:
        return 'Sender';
      case UserRole.traveller:
        return 'Traveller';
      case UserRole.both:
        return 'Sender & Traveller';
      case UserRole.receiver:
        return 'Receiver';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}
