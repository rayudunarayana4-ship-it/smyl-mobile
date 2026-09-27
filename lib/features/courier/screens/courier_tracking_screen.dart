import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/services/app_repository.dart';
import '../../../shared/services/courier_service.dart';

class CourierTrackingScreen extends ConsumerStatefulWidget {
  final String? trackingId;
  final TransactionModel? transaction;

  const CourierTrackingScreen({
    super.key,
    this.trackingId,
    this.transaction,
  });

  @override
  ConsumerState<CourierTrackingScreen> createState() => _CourierTrackingScreenState();
}

class _CourierTrackingScreenState extends ConsumerState<CourierTrackingScreen> {
  late String _trackingId;

  @override
  void initState() {
    super.initState();
    _trackingId = widget.trackingId ??
        widget.transaction?.courierTrackingId ??
        MockCourierService.defaultTrackingId;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final tx = widget.transaction ?? repo.primaryTransaction;
    final info = repo.courierService.getTrackingInfo(_trackingId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courier Logistics',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Waybill: $_trackingId',
              style: AppTypography.labelSmall.copyWith(color: AppColors.slateLight),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partner & Active Stage Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.electricCyan.withOpacity(0.12),
                    AppColors.surfaceCard,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.electricCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.obsidian,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping_outlined,
                                size: 14, color: AppColors.electricCyan),
                            const SizedBox(width: 6),
                            Text(
                              info.partnerName,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.warmIvory,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          info.currentStage.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dubai Gateway → Final Doorstep',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    info.currentStage.description,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned Courier Rider',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.slateLight),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            info.riderName,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.warmIvory,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling rider at ${info.riderPhone}...'),
                              backgroundColor: AppColors.surfaceCard,
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone_in_talk, color: AppColors.electricCyan),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.electricCyan.withOpacity(0.15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // OTP Delivery Security Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.key, color: AppColors.warning, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Handover OTP Required',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.warmIvory,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Receiver Rahul Kumar must disclose OTP ${tx.destinationHandoverOtp} upon parcel arrival to release package & escrow.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4-Stage Courier Milestones
            Text(
              'Courier Waypoint Timeline',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.warmIvory,
              ),
            ),
            const SizedBox(height: 14),

            ...info.events.asMap().entries.map((entry) {
              final idx = entry.key;
              final evt = entry.value;
              final isLast = idx == info.events.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: evt.isCompleted
                                ? AppColors.electricCyan
                                : AppColors.surfaceCard,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: evt.isCompleted
                                  ? AppColors.electricCyan
                                  : AppColors.surfaceBorder,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            evt.isCompleted ? Icons.check : Icons.circle,
                            size: evt.isCompleted ? 16 : 8,
                            color: evt.isCompleted ? AppColors.obsidian : AppColors.slate,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: evt.isCompleted
                                  ? AppColors.electricCyan.withOpacity(0.5)
                                  : AppColors.surfaceBorder,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              evt.title,
                              style: AppTypography.titleSmall.copyWith(
                                color: evt.isCompleted
                                    ? AppColors.warmIvory
                                    : AppColors.slateLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              evt.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.slateLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 12, color: AppColors.slate),
                                const SizedBox(width: 4),
                                Text(
                                  evt.location,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.slate,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            // Demo Simulation Tool
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepSpace,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.bolt, color: AppColors.warning, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Demo Workflow Simulator',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Step courier lifecycle forward to test real-time state changes.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.slateLight),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final updated = repo.advanceCourierTracking(tx.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Courier Stage Updated: ${updated.currentStage.label}'),
                          backgroundColor: AppColors.surfaceCard,
                        ),
                      );
                    },
                    icon: const Icon(Icons.fast_forward, size: 18),
                    label: const Text('Advance Courier Stage'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceBorder,
                      foregroundColor: AppColors.warmIvory,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
