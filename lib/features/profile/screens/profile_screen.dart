import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/app_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final user = repo.currentUser;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROFILE & SECURITY',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.slateLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.electricCyan,
                      size: 20,
                    ),
                    onPressed: () {
                      _showRoleSwitchModal(context, ref, user.role);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile Card
              SmylCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.electricCyan, AppColors.auroraTeal],
                            ),
                            border: Border.all(
                              color: AppColors.warmIvory.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.name.split(' ').map((n) => n[0]).take(2).join(),
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.obsidian,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: AppColors.slateLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.country} • Verified Resident',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.slateLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SmylStatusBadge(
                                    customLabel: user.kycStatus.label,
                                    customColor: user.kycStatus == KycStatus.verified
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.deepSpace,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: AppColors.surfaceBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 13,
                                          color: AppColors.champagneSand,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.rating.toString(),
                                          style: AppTypography.labelUppercase.copyWith(
                                            color: AppColors.champagneSand,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: AppColors.surfaceBorder),
                    ),
                    // Quick Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProfileStat(
                          label: 'DELIVERIES',
                          value: user.completedDeliveries.toString(),
                          color: AppColors.auroraTeal,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.surfaceBorder,
                        ),
                        _buildProfileStat(
                          label: 'SHIPMENTS',
                          value: user.completedShipments.toString(),
                          color: AppColors.electricCyan,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: AppColors.surfaceBorder,
                        ),
                        _buildProfileStat(
                          label: 'TRUST TIER',
                          value: 'Tier 1 Global',
                          color: AppColors.champagneSand,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Active Role Switcher Card
              SmylCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.deepSpace,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: AppColors.electricCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT OPERATING ROLE',
                            style: AppTypography.labelUppercase.copyWith(
                              fontSize: 10,
                              color: AppColors.slate,
                            ),
                          ),
                          Text(
                            user.role.name.toUpperCase(),
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.electricCyan,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showRoleSwitchModal(context, ref, user.role),
                      child: Text(
                        'Change',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.auroraTeal,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu Sections
              Text(
                'ACCOUNT & VERIFICATION',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 10),
              SmylCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.verified_user_rounded,
                      title: 'Identity Verification (KYC)',
                      subtitle: 'Passport bio-data & Government ID status',
                      badge: user.kycStatus.label,
                      badgeColor: user.kycStatus == KycStatus.verified
                          ? AppColors.success
                          : AppColors.warning,
                      onTap: () => context.push(AppRoutes.kycVerification),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment & Payout Accounts',
                      subtitle: 'UPI, Bank wire details, and Escrow vault',
                      onTap: () => context.push(AppRoutes.earnings),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Prohibited Items Directory',
                      subtitle: 'Customs compliance & restricted goods checklist',
                      onTap: () => context.push(AppRoutes.prohibitedItems),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'GOVERNANCE & CLAIMS',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 10),
              SmylCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.assignment_late_outlined,
                      title: 'Claims & Disputes Center',
                      subtitle: 'Report damaged, lost, or delayed consignments',
                      onTap: () => context.push(AppRoutes.claims),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.security_rounded,
                      title: 'Security & Two-Factor Passkeys',
                      subtitle: 'Biometric authorization and device logs',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Operations Control',
                      subtitle: 'Role-protected operations tower for SMYL HQ',
                      badge: 'RESTRICTED',
                      badgeColor: AppColors.champagneSand,
                      onTap: () => context.push(AppRoutes.admin),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Network Offline Simulator Toggle
              SmylCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      repo.isOnline
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      color: repo.isOnline
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repo.isOnline ? 'Online Protocol Active' : 'Offline Traveller Mode',
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            repo.isOnline
                                ? 'All transactions synced with SMYL cloud'
                                : 'Actions queued locally (${repo.offlineQueueCount} pending)',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: repo.isOnline,
                      onChanged: (val) => repo.toggleConnectivity(),
                      activeColor: AppColors.electricCyan,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  label: Text(
                    'Log Out of SMYL Global',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.danger,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slate,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.deepSpace,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.warmIvory, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.slate).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (badgeColor ?? AppColors.slate).withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            badge,
                            style: AppTypography.labelUppercase.copyWith(
                              fontSize: 9,
                              color: badgeColor ?? AppColors.slate,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(color: AppColors.surfaceBorder),
    );
  }

  void _showRoleSwitchModal(
      BuildContext context, WidgetRef ref, UserRole currentRole) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWITCH ACTIVE ROLE',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choose how you want to experience SMYL Global right now:',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              ...UserRole.values.map((role) {
                final isSelected = currentRole == role;
                return ListTile(
                  title: Text(
                    role.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.electricCyan
                          : AppColors.warmIvory,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.electricCyan)
                      : null,
                  onTap: () {
                    ref.read(appRepositoryProvider).switchUserRole(role);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
