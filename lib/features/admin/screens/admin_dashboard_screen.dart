import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/app_repository.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showConfirmActionDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            content,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.slateLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.slate,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.warmIvory,
                minimumSize: const Size(110, 42),
              ),
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Execute Action'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final transactions = repo.transactions;
    final claims = repo.claims;
    final auditLogs = repo.auditLogs;

    final inTransitCount = transactions
        .where((t) => t.status == TransactionStatus.inTransit)
        .length;
    final onHoldCount = transactions
        .where((t) => t.status == TransactionStatus.onHold)
        .length;
    final totalPaymentVolume =
        transactions.fold(0.0, (sum, t) => sum + t.totalAmount);
    final totalPayouts =
        transactions.fold(0.0, (sum, t) => sum + t.travellerPayout);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.electricCyan,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SMYL GLOBAL COMMAND CENTER',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.warmIvory,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.electricCyan,
          indicatorWeight: 3,
          labelColor: AppColors.electricCyan,
          unselectedLabelColor: AppColors.slate,
          isScrollable: true,
          labelStyle: AppTypography.labelUppercase.copyWith(fontSize: 10),
          tabs: const [
            Tab(text: 'DASHBOARD'),
            Tab(text: 'KYC & USERS'),
            Tab(text: 'TRANSACTIONS'),
            Tab(text: 'AUDIT LOGS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Dashboard Overview
          _buildDashboardOverview(
            activeTrxCount: transactions.length,
            inTransitCount: inTransitCount,
            claimsCount: claims.length,
            onHoldCount: onHoldCount,
            volume: totalPaymentVolume,
            payouts: totalPayouts,
          ),

          // Tab 2: KYC & User Privileges
          _buildUserKycTab(repo),

          // Tab 3: Transactions & Escrow Holds
          _buildTransactionsTab(repo),

          // Tab 4: Immutable Audit Trail
          _buildAuditLogsTab(auditLogs),
        ],
      ),
    );
  }

  Widget _buildDashboardOverview({
    required int activeTrxCount,
    required int inTransitCount,
    required int claimsCount,
    required int onHoldCount,
    required double volume,
    required double payouts,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          'OPERATIONAL METRICS',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 12),

        // Grid of 4 Metric Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'ACTIVE CONSIGNMENTS',
                value: activeTrxCount.toString(),
                color: AppColors.electricCyan,
                icon: Icons.hub_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'IN AIR TRANSIT',
                value: inTransitCount.toString(),
                color: AppColors.auroraTeal,
                icon: Icons.flight_takeoff_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'OPEN CLAIMS',
                value: claimsCount.toString(),
                color: AppColors.warning,
                icon: Icons.shield_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'ON HOLD / EXCEPTION',
                value: onHoldCount.toString(),
                color: AppColors.danger,
                icon: Icons.pause_circle_outline_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Financial Volume Card
        SmylCard(
          isHighlighted: true,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESCROW SETTLEMENT ENGINE',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.champagneSand,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Gross Escrow',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.slateLight),
                      ),
                      Text(
                        '₹${volume.toStringAsFixed(0)}',
                        style: AppTypography.currencyHighlight
                            .copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Traveller Net Payouts',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.slateLight),
                      ),
                      Text(
                        '₹${payouts.toStringAsFixed(0)}',
                        style: AppTypography.currencyHighlight.copyWith(
                          fontSize: 22,
                          color: AppColors.auroraTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick Admin Actions
        Text(
          'EMERGENCY CONTROL ACTIONS',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SmylButton(
                text: 'Policy Rules',
                variant: SmylButtonVariant.secondary,
                height: 42,
                onPressed: () => context.push(AppRoutes.prohibitedItems),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SmylButton(
                text: 'All Claims',
                variant: SmylButtonVariant.outline,
                height: 42,
                onPressed: () => context.push(AppRoutes.claims),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return SmylCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: AppTypography.displayMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.labelUppercase.copyWith(
              fontSize: 8.5,
              color: AppColors.slateLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserKycTab(AppRepository repo) {
    final user = repo.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Text(
          'PENDING KYC QUEUE',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 12),

        SmylCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.name,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SmylStatusBadge(
                    customLabel: user.kycStatus.label,
                    customColor: user.kycStatus == KycStatus.verified
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${user.email} • ${user.phone}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Passport: ${user.passportNumber ?? 'Z8942104'} • ID: ${user.governmentIdNumber ?? 'XXXX-XXXX-8921'}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.champagneSand,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceBorder),
              ),

              // Action buttons: Approve, Request Info, Reject, Suspend
              Row(
                children: [
                  Expanded(
                    child: SmylButton(
                      text: 'Approve KYC',
                      height: 38,
                      variant: SmylButtonVariant.primary,
                      onPressed: () {
                        _showConfirmActionDialog(
                          title: 'Approve Verification',
                          content:
                              'Are you sure you want to verify ${user.name}? This activates full international luggage carrying capacity.',
                          onConfirm: () {
                            repo.updateKycStatus(KycStatus.verified);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SmylButton(
                      text: 'Reject / Suspend',
                      height: 38,
                      variant: SmylButtonVariant.danger,
                      onPressed: () {
                        _showConfirmActionDialog(
                          title: 'Suspend Carrier Privileges',
                          content:
                              'Are you sure you want to suspend ${user.name}? All active capacity postings will be delisted.',
                          onConfirm: () {
                            repo.updateKycStatus(KycStatus.suspended);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsTab(AppRepository repo) {
    final transactions = repo.transactions;

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isOnHold = tx.status == TransactionStatus.onHold;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: SmylCard(
            isHighlighted: isOnHold,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.id,
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.electricCyan,
                        fontSize: 10,
                      ),
                    ),
                    SmylStatusBadge(status: tx.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${tx.originCity} → ${tx.destCity}',
                  style: AppTypography.titleMedium
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sender: ${tx.senderName} • Carrier: ${tx.travellerName ?? 'Unassigned'}',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.slateLight),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SmylButton(
                        text: isOnHold
                            ? 'Release Escrow Hold'
                            : 'Place On Hold (Dispute)',
                        height: 38,
                        variant: isOnHold
                            ? SmylButtonVariant.primary
                            : SmylButtonVariant.outline,
                        onPressed: () {
                          _showConfirmActionDialog(
                            title: isOnHold ? 'Release Hold' : 'Place On Hold',
                            content: isOnHold
                                ? 'Are you sure you want to release the hold on ${tx.id} and resume delivery transit?'
                                : 'Are you sure you want to freeze transaction ${tx.id}? Payouts and handovers will be blocked.',
                            onConfirm: () {
                              repo.toggleTransactionHold(
                                tx.id,
                                !isOnHold,
                                'Administrative action by SMYL Operations',
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.electricCyan),
                      onPressed: () {
                        context.push(
                          '${AppRoutes.tracking}/${tx.id}',
                          extra: tx,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuditLogsTab(List auditLogs) {
    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: auditLogs.length,
      itemBuilder: (context, index) {
        final log = auditLogs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.deepSpace,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.action.toUpperCase(),
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.electricCyan,
                        fontSize: 9,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM HH:mm').format(log.timestamp),
                      style: AppTypography.bodySmall
                          .copyWith(fontSize: 10, color: AppColors.slate),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${log.previousStatus} → ${log.newStatus}',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log.reason,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.slateLight,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Admin: ${log.adminName} • Ref: ${log.referenceId}',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.slate.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
