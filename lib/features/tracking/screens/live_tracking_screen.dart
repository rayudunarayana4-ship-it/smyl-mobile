import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_route_visualizer.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/app_repository.dart';

class LiveTrackingScreen extends ConsumerWidget {
  final String? transactionId;
  final TransactionModel? transaction;

  const LiveTrackingScreen({
    super.key,
    this.transactionId,
    this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final targetId = transactionId ?? transaction?.id;
    final tx = targetId != null
        ? repo.transactions.firstWhere(
            (t) => t.id == targetId,
            orElse: () => repo.primaryTransaction,
          )
        : repo.primaryTransaction;

    final currentUser = repo.currentUser;
    final currentProgress = tx.status.standardProgressIndex;
    final trackingEvents = repo.getTrackingEventsFor(tx.id);

    final milestones = [
      _Milestone('Consignment Created', currentProgress >= 0, isCurrent: currentProgress == 0),
      _Milestone('Traveller Requested', currentProgress >= 1, isCurrent: currentProgress == 1),
      _Milestone('Traveller Accepted', currentProgress >= 2, isCurrent: currentProgress == 2),
      _Milestone('Escrow Payment Locked', currentProgress >= 3, isCurrent: currentProgress == 3),
      _Milestone('Ready for Airport Handover', currentProgress >= 4, isCurrent: currentProgress == 4),
      _Milestone('Origin OTP Verified (In Custody)', currentProgress >= 5, isCurrent: currentProgress == 5),
      _Milestone('Flight EK-527 In Transit', currentProgress >= 6, isCurrent: currentProgress == 6),
      _Milestone('Arrived at Destination Airport', currentProgress >= 7, isCurrent: currentProgress == 7),
      _Milestone('Delivery OTP Verified', currentProgress >= 9, isCurrent: currentProgress == 9),
      _Milestone('Completed & Payout Released', currentProgress >= 10, isCurrent: currentProgress == 10),
    ];

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          tx.id,
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          children: [
            // Route Header: HYDERABAD → DUBAI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSIGNMENT ROUTE',
                      style: AppTypography.labelUppercase.copyWith(
                        fontSize: 9,
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.originCity.toUpperCase()} → ${tx.destCity.toUpperCase()}',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                SmylStatusBadge(status: tx.status),
              ],
            ),

            const SizedBox(height: 16),

            // Route Visualization Card
            SmylCard(
              isHighlighted: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SmylRouteVisualizer(
                    originCode: tx.originAirportCode,
                    originCity: tx.originCity,
                    destCode: tx.destAirportCode,
                    destCity: tx.destCity,
                    flightNumber: 'EK-527 • Emirates',
                    progress: tx.status == TransactionStatus.completed || tx.status == TransactionStatus.delivered
                        ? 1.0
                        : (tx.status == TransactionStatus.inTransit
                            ? 0.65
                            : (currentProgress >= 5 ? 0.35 : 0.1)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: tx.status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Carrier: ${tx.travellerName ?? "Awaiting Assignment"}',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.champagneSand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dynamic Contextual Action Card
            _buildContextualActionCard(context, ref, tx, currentUser),

            const SizedBox(height: 28),

            // 10-Milestone Timeline
            Text(
              'TRANSACTION LIFECYCLE MILESTONES',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 16),

            ...milestones.asMap().entries.map((entry) {
              final idx = entry.key;
              final ms = entry.value;
              final isLast = idx == milestones.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ms.isCurrent
                              ? AppColors.electricCyan
                              : (ms.isDone
                                  ? AppColors.auroraTeal
                                  : AppColors.deepSpace),
                          border: Border.all(
                            color: ms.isCurrent
                                ? AppColors.electricCyan
                                : (ms.isDone
                                    ? AppColors.auroraTeal
                                    : AppColors.surfaceBorder),
                            width: 2,
                          ),
                          boxShadow: ms.isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppColors.electricCyan.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: ms.isDone && !ms.isCurrent
                              ? const Icon(Icons.check,
                                  size: 12, color: AppColors.obsidian)
                              : (ms.isCurrent
                                  ? Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.obsidian,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: ms.isDone
                              ? AppColors.auroraTeal.withOpacity(0.5)
                              : AppColors.surfaceBorder,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Padding(
                    padding: const EdgeInsets.only(top: 1.0),
                    child: Text(
                      ms.title,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 13.5,
                        fontWeight:
                            ms.isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: ms.isCurrent
                            ? AppColors.electricCyan
                            : (ms.isDone
                                ? AppColors.warmIvory
                                : AppColors.slate),
                      ),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 28),

            // Live Audit & Event Trail
            Text(
              'LIVE AUDIT EVENT TRAIL',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 12),

            ...trackingEvents.map((ev) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackgroundDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getEventIcon(ev.status),
                        size: 16,
                        color: ev.status.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ev.title,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                ev.actor,
                                style: TextStyle(
                                  color: AppColors.electricCyan.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ev.description,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.slateLight,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📍 ${ev.location} • ${ev.timestamp.hour.toString().padLeft(2, '0')}:${ev.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: AppColors.slate.withOpacity(0.8),
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualActionCard(
    BuildContext context,
    WidgetRef ref,
    TransactionModel tx,
    UserModel currentUser,
  ) {
    if (tx.status == TransactionStatus.openForMatching) {
      return SmylCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AWAITING TRAVELLER SELECTION',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.electricCyan,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Consignment is ready to be matched with verified travellers flying HYD → DXB.',
              style: TextStyle(color: AppColors.slateLight, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Find Matched Travellers (Radar) →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(AppRoutes.findTraveller),
            ),
          ],
        ),
      );
    }

    if (tx.status == TransactionStatus.accepted) {
      return SmylCard(
        isHighlighted: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRAVELLER ACCEPTED - AWAITING ESCROW PAYMENT',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.electricCyan,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Arjun Reddy accepted your delivery request. Deposit ₹${tx.totalAmount.toInt()} into secure escrow to lock your slot.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Authorize Escrow Payment (₹${tx.totalAmount.toInt()}) →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(AppRoutes.payment, extra: tx),
            ),
          ],
        ),
      );
    }

    if (tx.status == TransactionStatus.withCourierPartner ||
        tx.status == TransactionStatus.outForDelivery) {
      return SmylCard(
        isHighlighted: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ONWARD COURIER DISPATCHED',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'Waybill: SML-CP-829104',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.slateLight),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Package transferred to SMYL Logistics Partner in Dubai for doorstep delivery to Rahul Kumar.',
              style: TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Track Courier Partner (Live Waypoints) →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(AppRoutes.courierTracking, extra: tx),
            ),
          ],
        ),
      );
    }

    if (tx.status == TransactionStatus.readyForHandover ||
        tx.status == TransactionStatus.paymentConfirmed) {
      return SmylCard(
        isHighlighted: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AIRPORT HANDOVER ACTIVE',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.paymentReceipt),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: Text(
                    'View Receipt',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.electricCyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              currentUser.role == UserRole.sender
                  ? 'Your Origin Handover OTP is: ${tx.originHandoverOtp}. Show this to Arjun at Departure Gate 4.'
                  : 'Enter the 6-digit Origin OTP given by Lakshmi to take custody of the package.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Open OTP Handover Screen →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(
                '${AppRoutes.otpHandover}/${tx.id}',
                extra: tx,
              ),
            ),
          ],
        ),
      );
    }

    if (tx.status == TransactionStatus.arrivedAtDestination) {
      return SmylCard(
        isHighlighted: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ARRIVED IN DUBAI - READY FOR DELIVERY',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.emeraldVerified,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Flight landed. Rahul Kumar holds the secret delivery OTP (739104) to confirm package receipt.',
              style: TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Open Delivery OTP Screen →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(
                '${AppRoutes.receiverPortal}/${tx.id}',
                extra: tx,
              ),
            ),
          ],
        ),
      );
    }

    if (tx.status == TransactionStatus.completed || tx.status == TransactionStatus.delivered) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.emeraldVerified.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.emeraldVerified.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.emeraldVerified, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consignment Delivered & Settled',
                    style: TextStyle(
                      color: AppColors.emeraldVerified,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Escrow payout ₹${tx.travellerPayout.toInt()} has been successfully released to Arjun Reddy.',
                    style: const TextStyle(color: AppColors.slateLight, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  IconData _getEventIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.created:
      case TransactionStatus.openForMatching:
        return Icons.inventory_2_rounded;
      case TransactionStatus.travellerRequested:
      case TransactionStatus.accepted:
        return Icons.handshake_rounded;
      case TransactionStatus.paymentConfirmed:
        return Icons.account_balance_wallet_rounded;
      case TransactionStatus.readyForHandover:
      case TransactionStatus.handedToTraveller:
        return Icons.qr_code_rounded;
      case TransactionStatus.inTransit:
        return Icons.flight_takeoff_rounded;
      case TransactionStatus.arrivedAtDestination:
        return Icons.flight_land_rounded;
      case TransactionStatus.delivered:
      case TransactionStatus.completed:
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _Milestone {
  final String title;
  final bool isDone;
  final bool isCurrent;

  _Milestone(this.title, this.isDone, {this.isCurrent = false});
}
