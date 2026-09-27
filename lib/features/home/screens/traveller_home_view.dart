import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_route_visualizer.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/transaction_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class TravellerHomeView extends ConsumerWidget {
  const TravellerHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final user = repo.currentUser;
    final nextJourney = repo.journeys.isNotEmpty ? repo.journeys.first : null;
    final activeDeliveries = repo.transactions.where((t) {
      return t.status != TransactionStatus.delivered &&
          !t.status.isException;
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      children: [
        // Greeting & KYC Pill
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrier Mode Active',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.auroraTeal,
                    fontSize: 9,
                  ),
                ),
                Text(
                  user.name.split(' ').first,
                  style: AppTypography.displayMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.deepSpace,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      size: 15, color: AppColors.champagneSand),
                  const SizedBox(width: 4),
                  Text(
                    '${user.rating} (${user.completedDeliveries} Trips)',
                    style: AppTypography.labelUppercase.copyWith(
                      fontSize: 10,
                      color: AppColors.champagneSand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Quick Actions: Post Journey, Browse Requests, View Earnings
        Row(
          children: [
            Expanded(
              child: _buildTravellerAction(
                context,
                title: 'Post Journey',
                subtitle: 'List Capacity',
                icon: Icons.add_circle_outline_rounded,
                color: AppColors.electricCyan,
                onTap: () => context.push(AppRoutes.postJourney),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTravellerAction(
                context,
                title: 'Browse Requests',
                subtitle: '${repo.shipments.length} Available',
                icon: Icons.inbox_rounded,
                color: AppColors.auroraTeal,
                onTap: () => context.push(AppRoutes.findTraveller),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTravellerAction(
                context,
                title: 'Carrier Payouts',
                subtitle: '₹12,450',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.champagneSand,
                onTap: () => context.push(AppRoutes.earnings),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // REAL-TIME OPERATIONAL LIFECYCLE ACTION CARD FOR SMYL-2026-000184
        _buildOperationalActionCard(context, ref, repo.primaryTransaction, repo),

        // "Your next journey" Featured Card
        if (nextJourney != null) ...[
          Text(
            'YOUR NEXT FLIGHT JOURNEY',
            style: AppTypography.labelUppercase.copyWith(
              color: AppColors.slateLight,
            ),
          ),
          const SizedBox(height: 10),

          SmylCard(
            isHighlighted: true,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${nextJourney.flightNumber} • ${nextJourney.airline}',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.champagneSand,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.auroraTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CAPACITY: ${nextJourney.availableCapacityKg} KG',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.auroraTeal,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                SmylRouteVisualizer(
                  originCode: nextJourney.originAirportCode,
                  originCity: nextJourney.originCity,
                  destCode: nextJourney.destAirportCode,
                  destCity: nextJourney.destCity,
                  flightNumber: nextJourney.flightNumber,
                  progress: 0.25,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: AppColors.surfaceBorder),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Departure: ${DateFormat('d OCT, HH:mm').format(nextJourney.departureDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warmIvory,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Est. Earnings: ₹${nextJourney.estimatedEarnings.toStringAsFixed(0)}',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.electricCyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Active Deliveries Carrying Right Now
        Text(
          'ACTIVE CONSIGNMENTS CARRIED',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.slateLight,
          ),
        ),
        const SizedBox(height: 10),

        ...activeDeliveries.map((del) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SmylCard(
              padding: const EdgeInsets.all(16),
              onTap: () {
                context.push(
                  '${AppRoutes.tracking}/${del.id}',
                  extra: del,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        del.id,
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.electricCyan,
                          fontSize: 10,
                        ),
                      ),
                      SmylStatusBadge(status: del.status),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '${del.originCity} → ${del.destCity}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Item: ${del.itemDescription} (${del.weightKg} KG)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.slateLight,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Receiver: ${del.receiverName}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.warmIvory,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Payout: ₹${del.travellerPayout.toStringAsFixed(0)}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.champagneSand,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTravellerAction(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 9.5,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalActionCard(
    BuildContext context,
    WidgetRef ref,
    TransactionModel primaryTx,
    AppRepository repo,
  ) {
    if (primaryTx.status == TransactionStatus.travellerRequested) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B4B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.electricCyan, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricCyan.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.electricCyan,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⚡ NEW CONSIGNMENT REQUEST',
                        style: TextStyle(
                          color: AppColors.obsidian,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      primaryTx.id,
                      style: const TextStyle(
                        color: AppColors.warmIvory,
                        fontSize: 10.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Payout: ₹${primaryTx.travellerPayout.toInt()}',
                  style: const TextStyle(
                    color: AppColors.emeraldVerified,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${primaryTx.senderName} (+91 98490 12345) wants you to carry:',
              style: const TextStyle(color: AppColors.slateLight, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${primaryTx.itemDescription} (${primaryTx.weightKg} KG)',
              style: const TextStyle(
                color: AppColors.warmIvory,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'For Flight EK-527 • Hyderabad (${primaryTx.originAirportCode}) → Dubai (${primaryTx.destAirportCode})',
              style: const TextStyle(color: AppColors.champagneSand, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SmylButton(
                    text: 'Decline',
                    variant: SmylButtonVariant.secondary,
                    height: 40,
                    onPressed: () {
                      repo.rejectConsignment(primaryTx.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Consignment request declined. Returned to Open for Matching.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SmylButton(
                    text: 'Accept Request (₹${primaryTx.travellerPayout.toInt()}) →',
                    variant: SmylButtonVariant.primary,
                    height: 40,
                    onPressed: () {
                      repo.acceptConsignment(primaryTx.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Accepted! Waiting for Sender (Lakshmi) to authorize escrow payment.'),
                          backgroundColor: AppColors.emeraldVerified,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.accepted) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.champagneSand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CONSIGNMENT ACCEPTED • AWAITING ESCROW',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.champagneSand,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You accepted to carry ${primaryTx.id}. Lakshmi Narayana is authorizing ₹${primaryTx.totalAmount.toInt()} into SMYL Escrow. Switch to SENDER via the top switcher to complete payment.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.paymentConfirmed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emeraldVerified),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ESCROW LOCKED • REF ${primaryTx.paymentReference}',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.emeraldVerified,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${primaryTx.totalAmount.toInt()} safely locked in SMYL Escrow. Meet Lakshmi Narayana at Hyderabad Airport Gate 4 to initiate physical cargo handover.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Initiate Airport Handover Protocol →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () {
                repo.prepareHandover(primaryTx.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Handover protocol active! Ready to verify Origin OTP.'),
                    backgroundColor: AppColors.electricCyan,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.readyForHandover) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.electricCyan, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ORIGIN HANDOVER PROTOCOL (GATE 4)',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Inspect physical package seals with Lakshmi Narayana. Enter the 6-digit Origin OTP (482913) to assume legal carriage custody.',
              style: TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Enter Origin OTP (482913) →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () {
                context.push(
                  '${AppRoutes.otpHandover}/${primaryTx.id}',
                  extra: primaryTx,
                );
              },
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.handedToTraveller) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.electricCyan),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CONSIGNMENT IN YOUR CUSTODY',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Package securely checked-in for Flight EK-527 (HYD → DXB). Ready for departure.',
              style: TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Depart Hyderabad / Take Off (In Transit) →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () {
                repo.startJourney(primaryTx.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Flight EK-527 airborne! Consignment is In Transit.'),
                    backgroundColor: AppColors.electricCyan,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.inTransit) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.champagneSand),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FLIGHT EK-527 IN TRANSIT',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.champagneSand,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Cruising altitude en route to Dubai International Airport (DXB Terminal 3).',
              style: TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'Record Flight Landing in Dubai →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () {
                repo.arriveAtDestination(primaryTx.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Flight EK-527 landed safely in Dubai!'),
                    backgroundColor: AppColors.emeraldVerified,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.arrivedAtDestination) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.emeraldVerified, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ARRIVED IN DUBAI • READY FOR FINAL HANDOVER',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.emeraldVerified,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hand consignment to Rahul Kumar (${primaryTx.receiverPhone}) or transfer to SMYL Logistics Partner. Enter Delivery OTP (739104) to release ₹${primaryTx.travellerPayout.toInt()} escrow payout.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SmylButton(
                    text: 'Transfer to Courier →',
                    variant: SmylButtonVariant.secondary,
                    height: 42,
                    onPressed: () {
                      context.push(AppRoutes.courierTracking, extra: primaryTx);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SmylButton(
                    text: 'Enter OTP (739104) →',
                    variant: SmylButtonVariant.primary,
                    height: 42,
                    onPressed: () {
                      context.push(
                        '${AppRoutes.otpHandover}/${primaryTx.id}',
                        extra: primaryTx,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.withCourierPartner ||
        primaryTx.status == TransactionStatus.outForDelivery) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.electricCyan),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'HANDED OVER TO COURIER PARTNER',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Consignment ${primaryTx.id} handed to SMYL Logistics Partner (SML-CP-829104). Your ₹${primaryTx.travellerPayout.toInt()} payout will be automatically credited upon final receiver OTP verification.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'View Courier Tracking (SML-CP-829104) →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(AppRoutes.courierTracking, extra: primaryTx),
            ),
          ],
        ),
      );
    }

    if (primaryTx.status == TransactionStatus.completed ||
        primaryTx.status == TransactionStatus.delivered) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TRIP COMPLETED & SETTLED',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.success,
                    fontSize: 10,
                  ),
                ),
                SmylStatusBadge(status: primaryTx.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Delivery confirmed! Escrow payout of ₹${primaryTx.travellerPayout.toInt()} has been successfully credited to your bank account.',
              style: const TextStyle(color: AppColors.warmIvory, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SmylButton(
              text: 'View Shipment Overview & Settlement →',
              variant: SmylButtonVariant.primary,
              height: 42,
              onPressed: () => context.push(AppRoutes.transactionDetail, extra: primaryTx),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
