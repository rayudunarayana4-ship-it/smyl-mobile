import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../shared/models/journey_model.dart';
import '../../../shared/models/shipment_model.dart';
import '../../../shared/services/app_repository.dart';
import '../../../shared/services/mock_data_service.dart';

class FindTravellerScreen extends ConsumerStatefulWidget {
  final ShipmentModel? shipment;

  const FindTravellerScreen({super.key, this.shipment});

  @override
  ConsumerState<FindTravellerScreen> createState() =>
      _FindTravellerScreenState();
}

class _FindTravellerScreenState extends ConsumerState<FindTravellerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isMatching = true;
  String _matchingPhaseText = 'Scanning verified international flight schedules...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Matching sequence simulation
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _matchingPhaseText =
              'Checking luggage allowance & IATA dangerous goods compliance...';
        });
      }
    });

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _matchingPhaseText =
              'Calculating carrier trust tiers & matching scores...';
        });
      }
    });

    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        setState(() {
          _isMatching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _requestTraveller(JourneyModel journey, ShipmentModel shipment) {
    final repo = ref.read(appRepositoryProvider);
    final tx = repo.primaryTransaction;
    repo.requestTraveller(tx.id, journey);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.midnight,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'REQUEST DISPATCHED',
                  style: TextStyle(
                    color: AppColors.electricCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Request Sent to ${journey.travellerName}!',
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consignment ${tx.id} has been transmitted to Arjun Reddy for flight ${journey.flightNumber} (${journey.originCity} → ${journey.destCity}).',
                style: const TextStyle(color: AppColors.slateLight, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.touch_app_rounded, color: AppColors.champagneSand, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Demo Tip: Use the top Role Switcher to switch to TRAVELLER to accept this request!',
                        style: TextStyle(
                          color: AppColors.champagneSand,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SmylButton(
                text: 'Proceed to Escrow Payment (₹2,230) →',
                variant: SmylButtonVariant.primary,
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.payment, extra: tx);
                },
              ),
              const SizedBox(height: 10),
              SmylButton(
                text: 'View Live Tracking →',
                variant: SmylButtonVariant.secondary,
                onPressed: () {
                  Navigator.pop(context);
                  context.push('${AppRoutes.tracking}/${tx.id}', extra: tx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showJourneyDetailsModal(BuildContext context, JourneyModel journey) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.midnight,
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.deepSpace,
                    child: Text(
                      journey.travellerName
                          .split(' ')
                          .map((n) => n[0])
                          .take(2)
                          .join(),
                      style: const TextStyle(
                        color: AppColors.warmIvory,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          journey.travellerName,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${journey.airline} • ${journey.flightNumber}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.champagneSand,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.auroraTeal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 14, color: AppColors.auroraTeal),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: AppColors.auroraTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    _buildPaymentRow('Origin', '${journey.originCity} (${journey.originAirportCode})'),
                    const SizedBox(height: 8),
                    _buildPaymentRow('Destination', '${journey.destCity} (${journey.destAirportCode})'),
                    const SizedBox(height: 8),
                    _buildPaymentRow('Departure', DateFormat('d MMM yyyy, ').format(journey.departureDate) + journey.departureTime),
                    const SizedBox(height: 8),
                    _buildPaymentRow('Available Capacity', '${journey.availableCapacityKg} KG'),
                    const SizedBox(height: 8),
                    _buildPaymentRow('Handover Preference', journey.handoverPreference),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SmylButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                variant: SmylButtonVariant.secondary,
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildPaymentRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                AppTypography.bodySmall.copyWith(color: AppColors.slateLight)),
        Text(val,
            style: AppTypography.bodySmall.copyWith(
                color: AppColors.warmIvory, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final targetShipment = widget.shipment ??
        (repo.shipments.isNotEmpty
            ? repo.shipments.first
            : MockDataService.initialShipments.first);
    final journeys = repo.journeys;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'SMART TRAVELLER MATCHING',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: _isMatching
            ? _buildMatchingEngineAnimation(targetShipment)
            : _buildMatchesList(targetShipment, journeys),
      ),
    );
  }

  Widget _buildMatchingEngineAnimation(ShipmentModel shipment) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Pulse Radar & Route Nodes
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsating wave
                    Container(
                      width: 140 + _animController.value * 50,
                      height: 140 + _animController.value * 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.electricCyan
                              .withOpacity(0.4 * (1 - _animController.value)),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner orbit
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.deepSpace,
                        border: Border.all(
                          color: AppColors.electricCyan.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.radar_rounded,
                          size: 52,
                          color: AppColors.electricCyan,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),

            Text(
              'Intelligent Routing Match',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _matchingPhaseText,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.champagneSand,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Route Node Trajectory Diagram
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.deepSpace,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNodePill(shipment.pickupCity, Icons.trip_origin_rounded,
                      AppColors.electricCyan),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.slate, size: 16),
                  _buildNodePill('In-Flight Carrier', Icons.flight_rounded,
                      AppColors.champagneSand),
                  const Icon(Icons.arrow_forward_rounded,
                      color: AppColors.slate, size: 16),
                  _buildNodePill(shipment.destCity, Icons.pin_drop_rounded,
                      AppColors.auroraTeal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodePill(String title, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesList(
      ShipmentModel shipment, List<JourneyModel> journeys) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Header info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MATCHED TRAVELLERS',
                  style: AppTypography.labelUppercase.copyWith(
                    color: AppColors.slateLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${journeys.length} Available Carriers Found',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.electricCyan),
              onPressed: () {
                setState(() => _isMatching = true);
                Timer(const Duration(milliseconds: 1500), () {
                  if (mounted) setState(() => _isMatching = false);
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Matched Traveller Cards
        ...journeys.asMap().entries.map((entry) {
          final index = entry.key;
          final journey = entry.value;
          final matchScore = (96 - index * 6).clamp(80, 98);

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: SmylCard(
              isHighlighted: index == 0,
              padding: const EdgeInsets.all(16),
              onTap: () => _showJourneyDetailsModal(context, journey),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Name + Verified badge & Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.deepSpace,
                            child: Text(
                              journey.travellerName
                                  .split(' ')
                                  .map((n) => n[0])
                                  .take(2)
                                  .join(),
                              style: const TextStyle(
                                color: AppColors.warmIvory,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                journey.travellerName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (i) => const Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: AppColors.champagneSand,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${journey.travellerRating}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.champagneSand,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.auroraTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$matchScore% Match',
                          style: const TextStyle(
                            color: AppColors.auroraTeal,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Route & Date & Available capacity
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.deepSpace,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${journey.originCity} → ${journey.destCity}',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.warmIvory,
                              ),
                            ),
                            Text(
                              DateFormat('d MMM').format(journey.departureDate),
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.champagneSand,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available: ${journey.availableCapacityKg.toStringAsFixed(0)} KG',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.slateLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Flight ${journey.flightNumber}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.slate,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 5 Verification Checkmarks
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.deepSpace,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        _buildVerificationCheck('Route Match: ${journey.originCity} → ${journey.destCity}'),
                        const SizedBox(height: 4),
                        _buildVerificationCheck('Flight Confirmed: ${journey.airline} (${journey.flightNumber})'),
                        const SizedBox(height: 4),
                        _buildVerificationCheck('Capacity: ${journey.availableCapacityKg.toStringAsFixed(0)} KG available for consignment'),
                        const SizedBox(height: 4),
                        _buildVerificationCheck('Traveller: KYC Passport & Government ID Verified'),
                        const SizedBox(height: 4),
                        _buildVerificationCheck('SMYL Escrow Protection: Payout held until Delivery OTP'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Action Buttons: [ Request Carry ] [ Book & Pay ₹2,230 ]
                  Row(
                    children: [
                      Expanded(
                        child: SmylButton(
                          text: 'Request Carry',
                          onPressed: () =>
                              _requestTraveller(journey, shipment),
                          variant: SmylButtonVariant.secondary,
                          height: 42,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SmylButton(
                          text: 'Select & Pay ₹2,230',
                          onPressed: () {
                            final repo = ref.read(appRepositoryProvider);
                            repo.requestTraveller(repo.primaryTransaction.id, journey);
                            context.push(AppRoutes.payment, extra: repo.primaryTransaction);
                          },
                          variant: SmylButtonVariant.primary,
                          height: 42,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVerificationCheck(String label) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.warmIvory,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
