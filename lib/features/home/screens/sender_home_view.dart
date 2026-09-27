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
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class SenderHomeView extends ConsumerWidget {
  const SenderHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final activeTransaction = repo.primaryTransaction;
    final upcomingJourney = repo.primaryJourney;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      children: [
        // Headline & Short Explanation
        Text(
          'Move smarter\nwith every journey.',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Send permitted items with verified travellers.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.slateLight,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 24),

        // CARD 1: SEND AN ITEM (Visually Dominant Hero)
        SmylCard(
          isHighlighted: true,
          padding: const EdgeInsets.all(20),
          onTap: () => context.push(AppRoutes.createShipment),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.electricCyan.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.outbox_rounded,
                      color: AppColors.electricCyan,
                      size: 24,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.electricCyan,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'SEND AN ITEM',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.electricCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find a traveller for your delivery.',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              SmylButton(
                text: 'Send Item →',
                height: 44,
                variant: SmylButtonVariant.primary,
                onPressed: () => context.push(AppRoutes.createShipment),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // CARD 2: TRAVEL & CARRY (Second Core Hero)
        SmylCard(
          padding: const EdgeInsets.all(20),
          onTap: () => context.push(AppRoutes.postJourney),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.auroraTeal.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.luggage_rounded,
                      color: AppColors.auroraTeal,
                      size: 24,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.auroraTeal,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'TRAVEL & CARRY',
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.auroraTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share your available luggage space.',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              SmylButton(
                text: 'Post Journey →',
                height: 44,
                variant: SmylButtonVariant.secondary,
                onPressed: () => context.push(AppRoutes.postJourney),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ACTIVE SHIPMENT (Primary Operational Transaction SMYL-2026-000184)
        Text(
          'ACTIVE CONSIGNMENT',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 10),

        SmylCard(
          isHighlighted: true,
          padding: const EdgeInsets.all(18),
          onTap: () {
            context.push(
              AppRoutes.transactionDetail,
              extra: activeTransaction,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activeTransaction.id,
                    style: const TextStyle(
                      color: AppColors.electricCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                  SmylStatusBadge(status: activeTransaction.status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${activeTransaction.originCity} → ${activeTransaction.destCity}',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${activeTransaction.itemDescription} (${activeTransaction.weightKg} KG)',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const SizedBox(height: 10),

              // Human-centric status banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.obsidian,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTransaction.status.customerStatusText,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.electricCyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeTransaction.status.customerSubtext,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.slateLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_rounded,
                      size: 14, color: AppColors.champagneSand),
                  const SizedBox(width: 4),
                  Text(
                    'Receiver: ${activeTransaction.receiverName} (${activeTransaction.destCity})',
                    style: const TextStyle(
                      color: AppColors.champagneSand,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSenderActionCTA(context, ref, activeTransaction, repo),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // UPCOMING JOURNEY (Primary traveller EK-527)
        Text(
            'UPCOMING JOURNEY',
            style: AppTypography.labelUppercase.copyWith(
              color: AppColors.slateLight,
            ),
          ),
          const SizedBox(height: 10),

          SmylCard(
            padding: const EdgeInsets.all(18),
            onTap: () => context.push(AppRoutes.earnings),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${upcomingJourney.originCity} → ${upcomingJourney.destCity}',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('dd MMM').format(upcomingJourney.departureDate)} • Available: ${upcomingJourney.availableCapacityKg} KG',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slateLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${upcomingJourney.estimatedEarnings.toStringAsFixed(0)}',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.champagneSand,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

        // RECENT ACTIVITY (Clean, non-cluttered summary)
        Text(
          'RECENT ACTIVITY',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 10),

        if (repo.notifications.isNotEmpty)
          SmylCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () => context.push(AppRoutes.tracking),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 18, color: AppColors.auroraTeal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    repo.notifications.first.title,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Just now',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSenderActionCTA(
    BuildContext context,
    WidgetRef ref,
    TransactionModel tx,
    AppRepository repo,
  ) {
    if (tx.status == TransactionStatus.openForMatching) {
      return SmylButton(
        text: 'Find Matched Travellers (Radar) →',
        height: 42,
        variant: SmylButtonVariant.primary,
        onPressed: () => context.push(AppRoutes.findTraveller),
      );
    }
    if (tx.status == TransactionStatus.travellerRequested) {
      return SmylButton(
        text: 'Awaiting Arjun Reddy Response ⏳',
        height: 42,
        variant: SmylButtonVariant.secondary,
        onPressed: () {
          context.push('${AppRoutes.tracking}/${tx.id}', extra: tx);
        },
      );
    }
    if (tx.status == TransactionStatus.accepted) {
      return SmylButton(
        text: 'Authorize Escrow Payment (₹${tx.totalAmount.toInt()}) →',
        height: 42,
        variant: SmylButtonVariant.primary,
        onPressed: () {
          context.push(AppRoutes.payment, extra: tx);
        },
      );
    }
    if (tx.status == TransactionStatus.paymentConfirmed ||
        tx.status == TransactionStatus.readyForHandover) {
      return SmylButton(
        text: 'Airport Handover OTP (${tx.originHandoverOtp}) →',
        height: 42,
        variant: SmylButtonVariant.primary,
        onPressed: () {
          context.push('${AppRoutes.otpHandover}/${tx.id}', extra: tx);
        },
      );
    }
    if (tx.status == TransactionStatus.withCourierPartner ||
        tx.status == TransactionStatus.outForDelivery) {
      return SmylButton(
        text: 'Track Courier Partner (SML-CP-829104) →',
        height: 42,
        variant: SmylButtonVariant.primary,
        onPressed: () {
          context.push(AppRoutes.courierTracking, extra: tx);
        },
      );
    }
    if (tx.status == TransactionStatus.completed || tx.status == TransactionStatus.delivered) {
      return SmylButton(
        text: 'Delivered & Settled ✓ (View Overview)',
        height: 42,
        variant: SmylButtonVariant.secondary,
        onPressed: () {
          context.push(AppRoutes.transactionDetail, extra: tx);
        },
      );
    }
    return SmylButton(
      text: 'Live Consignment Tracking →',
      height: 42,
      variant: SmylButtonVariant.secondary,
      onPressed: () {
        context.push('${AppRoutes.tracking}/${tx.id}', extra: tx);
      },
    );
  }


}
