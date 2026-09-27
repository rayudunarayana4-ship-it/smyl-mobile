import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/transaction_status.dart';
import '../../shared/services/app_repository.dart';

class DemoRoleSwitcher extends ConsumerWidget {
  const DemoRoleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final currentUser = repo.currentUser;
    final primaryTx = repo.primaryTransaction;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: AppColors.electricCyan.withOpacity(0.35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top mini banner: Transaction ID & Live Status Tracker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            color: const Color(0xFF090D16),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _getStatusDotColor(primaryTx.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'MASTER TX: ',
                  style: TextStyle(
                    color: AppColors.slateLight.withOpacity(0.7),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  primaryTx.id,
                  style: const TextStyle(
                    color: AppColors.warmIvory,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '• ${primaryTx.status.label}',
                    style: TextStyle(
                      color: primaryTx.status.color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Reset scenario button
                InkWell(
                  onTap: () {
                    repo.resetDemoScenario();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Demo Scenario Reset to Initial State (SMYL-2026-000184 Open for Matching)'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.electricCyan,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 11,
                          color: AppColors.electricCyan.withOpacity(0.9),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'RESET',
                          style: TextStyle(
                            color: AppColors.electricCyan.withOpacity(0.9),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Role selection pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              children: [
                _buildRolePill(
                  context: context,
                  label: 'SENDER',
                  persona: 'Lakshmi',
                  icon: Icons.person_rounded,
                  isSelected: currentUser.role == UserRole.sender,
                  onTap: () => repo.switchDemoRole(UserRole.sender),
                ),
                const SizedBox(width: 6),
                _buildRolePill(
                  context: context,
                  label: 'TRAVELLER',
                  persona: 'Arjun',
                  icon: Icons.flight_takeoff_rounded,
                  isSelected: currentUser.role == UserRole.traveller,
                  onTap: () => repo.switchDemoRole(UserRole.traveller),
                ),
                const SizedBox(width: 6),
                _buildRolePill(
                  context: context,
                  label: 'RECEIVER',
                  persona: 'Rahul',
                  icon: Icons.markunread_mailbox_rounded,
                  isSelected: currentUser.role == UserRole.receiver,
                  onTap: () => repo.switchDemoRole(UserRole.receiver),
                ),
                const SizedBox(width: 6),
                _buildRolePill(
                  context: context,
                  label: 'ADMIN',
                  persona: 'Console',
                  icon: Icons.shield_rounded,
                  isSelected: currentUser.role == UserRole.admin,
                  onTap: () => repo.switchDemoRole(UserRole.admin),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusDotColor(TransactionStatus status) {
    if (status == TransactionStatus.completed || status == TransactionStatus.delivered) {
      return AppColors.emeraldVerified;
    }
    if (status == TransactionStatus.inTransit || status == TransactionStatus.handedToTraveller) {
      return AppColors.electricCyan;
    }
    if (status == TransactionStatus.onHold || status == TransactionStatus.disputed) {
      return AppColors.danger;
    }
    return AppColors.sunsetAmber;
  }

  Widget _buildRolePill({
    required BuildContext context,
    required String label,
    required String persona,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricCyan : AppColors.cardBackgroundDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.electricCyan : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.electricCyan.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? AppColors.obsidian : AppColors.slateLight,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.obsidian : AppColors.warmIvory,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              '($persona)',
              style: TextStyle(
                color: isSelected
                    ? AppColors.obsidian.withOpacity(0.8)
                    : AppColors.slateLight.withOpacity(0.7),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
