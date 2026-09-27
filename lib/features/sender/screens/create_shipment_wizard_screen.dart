import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_text_field.dart';
import '../../../shared/models/shipment_model.dart';
import '../../../shared/models/transaction_status.dart';
import '../../../shared/services/app_repository.dart';

class CreateShipmentWizardScreen extends ConsumerStatefulWidget {
  const CreateShipmentWizardScreen({super.key});

  @override
  ConsumerState<CreateShipmentWizardScreen> createState() =>
      _CreateShipmentWizardScreenState();
}

class _CreateShipmentWizardScreenState
    extends ConsumerState<CreateShipmentWizardScreen> {
  int _currentStep = 1; // 1: Route, 2: Item, 3: Receiver, 4: Review

  // Step 1: WHERE?
  final _fromCityController = TextEditingController(text: 'Hyderabad');
  final _toCityController = TextEditingController(text: 'Dubai');

  // Step 2: WHAT?
  final String _selectedCategory = 'Branded Apparel & Fashion';
  final _itemDescController =
      TextEditingController(text: 'Artisan Pashmina Shawl');
  double _weightKg = 2.0;

  // Step 3: WHO?
  final _receiverNameController =
      TextEditingController(text: 'Zayed Al-Hashimi');
  final _receiverPhoneController =
      TextEditingController(text: '+971 52 984 1049');

  // Step 4: Declaration
  bool _declarationAccepted = true;

  @override
  void dispose() {
    _fromCityController.dispose();
    _toCityController.dispose();
    _itemDescController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  double get _travellerPayout => (_weightKg * 900.0).clamp(1800.0, 9000.0);
  double get _platformFee => 180.0;
  double get _courierFee => 250.0;
  double get _totalEstimatedCost => _travellerPayout + _platformFee + _courierFee;

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _finalizeShipment();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _finalizeShipment() {
    final newShipmentId =
        'SMYL-SHP-${Random().nextInt(90000) + 10000}';
    final randomOriginOtp =
        (Random().nextInt(900000) + 100000).toString();
    final randomDeliveryOtp =
        (Random().nextInt(900000) + 100000).toString();

    final shipment = ShipmentModel(
      id: newShipmentId,
      senderId: ref.read(appRepositoryProvider).currentUser.id,
      senderName: ref.read(appRepositoryProvider).currentUser.name,
      pickupCity: _fromCityController.text,
      pickupCountry: 'India',
      pickupAddress: 'Terminal 2 Drop-off',
      destCity: _toCityController.text,
      destCountry: 'UAE',
      destAddress: 'Downtown Dubai',
      receiverName: _receiverNameController.text,
      receiverPhone: _receiverPhoneController.text,
      itemCategory: _selectedCategory,
      itemDescription: _itemDescController.text,
      weightKg: _weightKg,
      declaredValue: 8000.0,
      journeyType: JourneyType.international,
      declarationAccepted: _declarationAccepted,
      estimatedCost: _totalEstimatedCost,
      travellerPayout: _travellerPayout,
      platformFee: _platformFee,
      courierFee: _courierFee,
      status: TransactionStatus.openForMatching,
      originOtp: randomOriginOtp,
      deliveryOtp: randomDeliveryOtp,
      createdAt: DateTime.now(),
    );

    ref.read(appRepositoryProvider).createShipment(shipment);

    context.push(
      AppRoutes.findTraveller,
      extra: shipment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'SEND AN ITEM',
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

            // Smart Minimal Progress Indicator: 01 ─── 02 ─── 03 ─── 04
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
                text: _currentStep == 4 ? 'FIND TRAVELLER →' : 'CONTINUE →',
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
    final steps = ['Route', 'Item', 'Receiver', 'Review'];

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
                          ? AppColors.electricCyan
                          : (isCompleted
                              ? AppColors.auroraTeal
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
                      ? AppColors.auroraTeal
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
        return _buildStep2Item();
      case 3:
        return _buildStep3Receiver();
      case 4:
        return _buildStep4Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Route() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHERE?',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the origin and destination cities for your delivery.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 28),

        SmylTextField(
          controller: _fromCityController,
          label: 'FROM (ORIGIN)',
          hintText: 'e.g. Hyderabad',
          prefixIcon: const Icon(Icons.flight_takeoff_rounded,
              color: AppColors.champagneSand, size: 20),
        ),
        const SizedBox(height: 18),

        SmylTextField(
          controller: _toCityController,
          label: 'TO (DESTINATION)',
          hintText: 'e.g. Dubai',
          prefixIcon: const Icon(Icons.flight_land_rounded,
              color: AppColors.electricCyan, size: 20),
        ),
      ],
    );
  }

  Widget _buildStep2Item() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT?',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Describe the permitted item and estimated weight.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 24),

        SmylTextField(
          controller: _itemDescController,
          label: 'ITEM DESCRIPTION',
          hintText: 'e.g. Artisan Pashmina Shawl',
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'WEIGHT',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.electricCyan.withOpacity(0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_weightKg.toStringAsFixed(1)} KG',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.electricCyan,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _weightKg,
          min: 0.5,
          max: 10.0,
          divisions: 19,
          activeColor: AppColors.electricCyan,
          inactiveColor: AppColors.surfaceBorder,
          onChanged: (val) => setState(() => _weightKg = val),
        ),
      ],
    );
  }

  Widget _buildStep3Receiver() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHO?',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Who will receive and verify delivery via OTP at destination?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 24),

        SmylTextField(
          controller: _receiverNameController,
          label: 'RECEIVER NAME',
          hintText: 'e.g. Zayed Al-Hashimi',
          prefixIcon: const Icon(Icons.person_outline_rounded,
              color: AppColors.slate, size: 20),
        ),
        const SizedBox(height: 18),

        SmylTextField(
          controller: _receiverPhoneController,
          label: 'RECEIVER PHONE NUMBER',
          hintText: '+971 52 984 1049',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_iphone_rounded,
              color: AppColors.slate, size: 20),
        ),
      ],
    );
  }

  Widget _buildStep4Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVIEW & CONFIRM',
          style: AppTypography.displayMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review summary before smart carrier matching.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.slateLight),
        ),
        const SizedBox(height: 20),

        // Clean Summary Card
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
                    '${_weightKg.toStringAsFixed(1)} KG',
                    style: AppTypography.labelAccent.copyWith(
                      color: AppColors.electricCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _itemDescController.text,
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
                  Text('Carrier Reward', style: AppTypography.bodySmall),
                  Text('₹${_travellerPayout.toStringAsFixed(0)}',
                      style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmIvory)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SMYL Platform Fee (10%)',
                      style: AppTypography.bodySmall),
                  Text('₹${_platformFee.toStringAsFixed(0)}',
                      style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmIvory)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Onward Courier Delivery',
                      style: AppTypography.bodySmall),
                  Text('₹${_courierFee.toStringAsFixed(0)}',
                      style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warmIvory)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(color: AppColors.surfaceBorder),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Escrow Amount',
                      style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800)),
                  Text(
                    '₹${_totalEstimatedCost.toStringAsFixed(0)}',
                    style: AppTypography.currencyHighlight.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Compliance Agreement
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _declarationAccepted,
              onChanged: (val) =>
                  setState(() => _declarationAccepted = val ?? true),
              activeColor: AppColors.electricCyan,
              checkColor: AppColors.obsidian,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'I confirm this item is legal, non-hazardous, and permitted by origin and destination customs.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slateLight,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
