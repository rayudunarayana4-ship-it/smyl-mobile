import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_text_field.dart';
import '../../../shared/models/journey_model.dart';
import '../../../shared/services/app_repository.dart';

class PostJourneyScreen extends ConsumerStatefulWidget {
  const PostJourneyScreen({super.key});

  @override
  ConsumerState<PostJourneyScreen> createState() => _PostJourneyScreenState();
}

class _PostJourneyScreenState extends ConsumerState<PostJourneyScreen> {
  int _currentStep = 1; // 1: Route, 2: When, 3: Capacity, 4: Publish

  // Step 1: WHERE?
  final _fromCityController = TextEditingController(text: 'Hyderabad');
  final _toCityController = TextEditingController(text: 'Dubai');

  // Step 2: WHEN?
  DateTime _travelDate = DateTime.now().add(const Duration(days: 2));
  final _departureTimeController = TextEditingController(text: '10:30 AM');

  // Step 3: CAPACITY?
  double _availableKg = 5.0;

  // Step 4: ADVANCED / MORE DETAILS (Expandable)
  bool _showAdvancedDetails = false;
  final _airlineController = TextEditingController(text: 'Emirates');
  final _flightNumController = TextEditingController(text: 'EK-527');

  @override
  void dispose() {
    _fromCityController.dispose();
    _toCityController.dispose();
    _departureTimeController.dispose();
    _airlineController.dispose();
    _flightNumController.dispose();
    super.dispose();
  }

  double get _estimatedEarnings => _availableKg * 1500.0;

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _publishJourney();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _publishJourney() {
    final user = ref.read(appRepositoryProvider).currentUser;
    final newId = 'SMYL-JRN-${Random().nextInt(9000) + 1000}';

    final journey = JourneyModel(
      id: newId,
      travellerId: user.id,
      travellerName: user.name,
      travellerRating: user.rating,
      originCity: _fromCityController.text,
      originCountry: 'India',
      originAirportCode: _fromCityController.text.substring(0, 3).toUpperCase(),
      destCity: _toCityController.text,
      destCountry: 'UAE',
      destAirportCode: _toCityController.text.substring(0, 3).toUpperCase(),
      departureDate: _travelDate,
      departureTime: _departureTimeController.text,
      arrivalDate: _travelDate,
      arrivalTime: '01:30 PM',
      airline: _airlineController.text,
      flightNumber: _flightNumController.text,
      totalCapacityKg: _availableKg,
      availableCapacityKg: _availableKg,
      isInternational: true,
      handoverPreference: 'Airport Departure Terminal',
      status: JourneyStatus.active,
      estimatedEarnings: _estimatedEarnings,
    );

    ref.read(appRepositoryProvider).postJourney(journey);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Journey $newId published! Your carrying capacity is live.'),
        backgroundColor: AppColors.success,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'POST A JOURNEY',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Smart Progress Indicator: 01 ─── 02 ─── 03 ─── 04
            _buildSmartProgressIndicator(),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildCurrentStepContent(),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.deepSpace,
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: SmylButton(
                text: _currentStep == 4 ? 'PUBLISH JOURNEY →' : 'CONTINUE →',
                variant: SmylButtonVariant.primary,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartProgressIndicator() {
    final steps = ['Route', 'When', 'Space', 'Publish'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          final stepNum = index + 1;
          final isActive = _currentStep == stepNum;
          final isCompleted = _currentStep > stepNum;

          return Row(
            children: [
              Column(
                children: [
                  Text(
                    '0$stepNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? AppColors.auroraTeal
                          : (isCompleted
                              ? AppColors.electricCyan
                              : AppColors.slate),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppColors.warmIvory
                          : AppColors.slateLight,
                    ),
                  ),
                ],
              ),
              if (index < 3) ...[
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 2,
                  color: isCompleted
                      ? AppColors.electricCyan
                      : AppColors.surfaceBorder,
                ),
                const SizedBox(width: 8),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Route();
      case 2:
        return _buildStep2When();
      case 3:
        return _buildStep3Space();
      case 4:
        return _buildStep4Publish();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Route() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHERE ARE YOU GOING?',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your flight origin and destination cities.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 28),

        SmylTextField(
          controller: _fromCityController,
          label: 'FROM (DEPARTURE CITY)',
          hintText: 'e.g. Hyderabad',
          prefixIcon: const Icon(Icons.flight_takeoff_rounded,
              color: AppColors.champagneSand, size: 20),
        ),
        const SizedBox(height: 18),

        SmylTextField(
          controller: _toCityController,
          label: 'TO (ARRIVAL CITY)',
          hintText: 'e.g. Dubai',
          prefixIcon: const Icon(Icons.flight_land_rounded,
              color: AppColors.auroraTeal, size: 20),
        ),
      ],
    );
  }

  Widget _buildStep2When() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHEN?',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select your travel date and expected flight departure time.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 28),

        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _travelDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _travelDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepSpace,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: AppColors.auroraTeal, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM, yyyy').format(_travelDate),
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
                Text(
                  'Change',
                  style: AppTypography.labelAccent.copyWith(
                    color: AppColors.electricCyan,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        SmylTextField(
          controller: _departureTimeController,
          label: 'DEPARTURE TIME',
          hintText: '10:30 AM',
          prefixIcon: const Icon(Icons.access_time_rounded,
              color: AppColors.slate, size: 20),
        ),
      ],
    );
  }

  Widget _buildStep3Space() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW MUCH SPACE?',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Set your unused luggage capacity available for carry.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 28),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AVAILABLE CAPACITY',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.auroraTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_availableKg.toStringAsFixed(1)} KG',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.auroraTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _availableKg,
          min: 1.0,
          max: 15.0,
          divisions: 14,
          activeColor: AppColors.auroraTeal,
          inactiveColor: AppColors.surfaceBorder,
          onChanged: (val) => setState(() => _availableKg = val),
        ),
        const SizedBox(height: 24),

        // Estimated Earnings Box
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.deepSpace,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTIMATED EARNINGS',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.champagneSand,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_estimatedEarnings.toStringAsFixed(0)}',
                    style: AppTypography.currencyHighlight.copyWith(fontSize: 26),
                  ),
                ],
              ),
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.champagneSand,
                size: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep4Publish() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'READY TO PUBLISH',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your itinerary will be visible to senders with matching routes.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 20),

        // Route Summary Card
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
                    '${_fromCityController.text} → ${_toCityController.text}',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_availableKg.toStringAsFixed(1)} KG',
                    style: AppTypography.labelAccent.copyWith(
                      color: AppColors.auroraTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${DateFormat('d MMMM yyyy').format(_travelDate)} • ${_departureTimeController.text}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slateLight,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppColors.surfaceBorder),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated Carrier Payout',
                      style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700)),
                  Text(
                    '₹${_estimatedEarnings.toStringAsFixed(0)}',
                    style: AppTypography.currencyHighlight.copyWith(
                      fontSize: 22,
                      color: AppColors.auroraTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // "More details" progressive disclosure toggle
        GestureDetector(
          onTap: () => setState(() => _showAdvancedDetails = !_showAdvancedDetails),
          child: Row(
            children: [
              Icon(
                _showAdvancedDetails
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.electricCyan,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                _showAdvancedDetails
                    ? 'Hide flight details'
                    : 'Add flight number & airline (optional)',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.electricCyan,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        if (_showAdvancedDetails) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SmylTextField(
                  controller: _airlineController,
                  label: 'AIRLINE',
                  hintText: 'e.g. Emirates',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SmylTextField(
                  controller: _flightNumController,
                  label: 'FLIGHT NUMBER',
                  hintText: 'e.g. EK-527',
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
