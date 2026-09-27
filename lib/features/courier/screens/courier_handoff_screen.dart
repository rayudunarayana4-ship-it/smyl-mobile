import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../core/widgets/smyl_text_field.dart';
import '../../../shared/models/courier_partner_model.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';
import '../../../shared/services/mock_data_service.dart';

class CourierHandoffScreen extends ConsumerStatefulWidget {
  final String? transactionId;
  final TransactionModel? transaction;

  const CourierHandoffScreen({
    super.key,
    this.transactionId,
    this.transaction,
  });

  @override
  ConsumerState<CourierHandoffScreen> createState() =>
      _CourierHandoffScreenState();
}

class _CourierHandoffScreenState extends ConsumerState<CourierHandoffScreen> {
  late CourierPartnerModel _selectedPartner;
  final _trackingIdController = TextEditingController(text: 'ARX-DXB-998231');
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    final partners = ref.read(appRepositoryProvider).courierPartners;
    _selectedPartner = partners.first;
  }

  @override
  void dispose() {
    _trackingIdController.dispose();
    super.dispose();
  }

  TransactionModel _getTransaction() {
    final repo = ref.read(appRepositoryProvider);
    final targetId = widget.transactionId ?? widget.transaction?.id ?? 'SMYL-TRX-10482';
    return repo.transactions.firstWhere(
      (t) => t.id == targetId,
      orElse: () => repo.transactions.isNotEmpty
          ? repo.transactions.first
          : MockDataService.initialTransactions.first,
    );
  }

  void _assignCourier() {
    final tx = _getTransaction();
    setState(() => _isAssigning = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isAssigning = false);
        ref.read(appRepositoryProvider).assignCourierPartner(
              transactionId: tx.id,
              courier: _selectedPartner,
              trackingId: _trackingIdController.text,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consignment transferred to ${_selectedPartner.name} successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _advanceToOutForDelivery() {
    final tx = _getTransaction();
    ref.read(appRepositoryProvider).updateTransactionStatus(
          tx.id,
          TransactionStatus.outForDelivery,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status updated to OUT FOR DELIVERY.'),
        backgroundColor: AppColors.electricCyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final tx = _getTransaction();
    final partners = repo.courierPartners;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'COURIER PARTNER HANDOFF',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flow Diagram
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      'LAST-MILE MULTI-MODAL LOGISTICS',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.electricCyan,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStageNode('Traveller', Icons.flight_takeoff_rounded,
                            isPassed: true),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.slate),
                        _buildStageNode(
                            'Airport Gateway', Icons.connecting_airports_rounded,
                            isPassed: true),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.slate),
                        _buildStageNode(
                            'Courier Partner', Icons.local_shipping_rounded,
                            isCurrent: true),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: AppColors.slate),
                        _buildStageNode('Final Receiver', Icons.home_rounded),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Active Consignment Card
              SmylCard(
                padding: const EdgeInsets.all(18),
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
                    const SizedBox(height: 10),
                    Text(
                      'Arrival Gateway: ${tx.destCity} International (${tx.destAirportCode})',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Consignment: ${tx.itemDescription} • ${tx.weightKg} KG',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slateLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Final Destination: ${tx.receiverName} • ${tx.destCity}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.champagneSand,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Select Courier Partner
              Text(
                'OFFICIAL COURIER INTEGRATION PARTNER',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 10),

              ...partners.map((p) {
                final isSelected = _selectedPartner.id == p.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: SmylCard(
                    isHighlighted: isSelected,
                    onTap: () => setState(() => _selectedPartner = p),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.electricCyan.withOpacity(0.18)
                                : AppColors.deepSpace,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.electricCyan
                                  : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              p.code,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.electricCyan
                                    : AppColors.warmIvory,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: AppTypography.titleMedium
                                    .copyWith(fontSize: 14),
                              ),
                              Text(
                                '${p.serviceTier} • Avg ${p.averageTransitHours.toStringAsFixed(0)}h transit',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.slate,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.electricCyan, size: 20),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Tracking ID Input
              SmylTextField(
                controller: _trackingIdController,
                label: 'PARTNER TRACKING / WAYBILL ID',
                hintText: 'e.g. ARX-DXB-998231',
                prefixIcon: const Icon(Icons.qr_code_rounded,
                    color: AppColors.slate, size: 20),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              SmylButton(
                text: 'Transfer Custody to ${_selectedPartner.name}',
                onPressed: _assignCourier,
                isLoading: _isAssigning,
                variant: SmylButtonVariant.primary,
              ),

              if (tx.status == TransactionStatus.withCourierPartner) ...[
                const SizedBox(height: 12),
                SmylButton(
                  text: 'Mark As OUT FOR DELIVERY',
                  onPressed: _advanceToOutForDelivery,
                  variant: SmylButtonVariant.secondary,
                ),
              ],

              const SizedBox(height: 12),
              SmylButton(
                text: 'Return to Live Tracking',
                onPressed: () => context.pop(),
                variant: SmylButtonVariant.outline,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageNode(String title, IconData icon,
      {bool isPassed = false, bool isCurrent = false}) {
    Color color = AppColors.slate;
    if (isPassed) color = AppColors.auroraTeal;
    if (isCurrent) color = AppColors.electricCyan;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 1.2),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
