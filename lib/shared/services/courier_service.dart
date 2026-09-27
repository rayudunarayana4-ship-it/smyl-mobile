enum CourierStage {
  packageReceived,
  shipmentProcessed,
  outForDelivery,
  delivered,
}

extension CourierStageExtension on CourierStage {
  String get label {
    switch (this) {
      case CourierStage.packageReceived:
        return 'Package Received at Gateway Hub';
      case CourierStage.shipmentProcessed:
        return 'Shipment Processed & Sorted';
      case CourierStage.outForDelivery:
        return 'Out for Delivery';
      case CourierStage.delivered:
        return 'Delivered';
    }
  }

  String get description {
    switch (this) {
      case CourierStage.packageReceived:
        return 'Package checked in at Dubai Gateway Hub (DXB Cargo Village).';
      case CourierStage.shipmentProcessed:
        return 'Customs clearance completed; assigned to local distribution route.';
      case CourierStage.outForDelivery:
        return 'Courier rider Mohammed S. dispatched for doorstep delivery.';
      case CourierStage.delivered:
        return 'Consignment safely handed over to Rahul Kumar.';
    }
  }

  int get stepIndex {
    switch (this) {
      case CourierStage.packageReceived:
        return 0;
      case CourierStage.shipmentProcessed:
        return 1;
      case CourierStage.outForDelivery:
        return 2;
      case CourierStage.delivered:
        return 3;
    }
  }
}

class CourierTrackingEvent {
  final String id;
  final CourierStage stage;
  final String title;
  final String description;
  final String location;
  final DateTime timestamp;
  final bool isCompleted;

  const CourierTrackingEvent({
    required this.id,
    required this.stage,
    required this.title,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.isCompleted,
  });
}

class CourierShipmentInfo {
  final String partnerName;
  final String trackingId;
  final String originHub;
  final String destinationAddress;
  final String riderName;
  final String riderPhone;
  final CourierStage currentStage;
  final DateTime estimatedDeliveryTime;
  final List<CourierTrackingEvent> events;

  const CourierShipmentInfo({
    required this.partnerName,
    required this.trackingId,
    required this.originHub,
    required this.destinationAddress,
    required this.riderName,
    required this.riderPhone,
    required this.currentStage,
    required this.estimatedDeliveryTime,
    required this.events,
  });

  CourierShipmentInfo copyWith({
    String? partnerName,
    String? trackingId,
    String? originHub,
    String? destinationAddress,
    String? riderName,
    String? riderPhone,
    CourierStage? currentStage,
    DateTime? estimatedDeliveryTime,
    List<CourierTrackingEvent>? events,
  }) {
    return CourierShipmentInfo(
      partnerName: partnerName ?? this.partnerName,
      trackingId: trackingId ?? this.trackingId,
      originHub: originHub ?? this.originHub,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      currentStage: currentStage ?? this.currentStage,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      events: events ?? this.events,
    );
  }
}

abstract class CourierService {
  CourierShipmentInfo getTrackingInfo(String trackingId);
  CourierShipmentInfo advanceCourierStage(String trackingId);
  List<CourierTrackingEvent> buildEventsForStage(CourierStage stage);
}

class MockCourierService implements CourierService {
  static const String defaultTrackingId = 'SML-CP-829104';
  static const String defaultPartner = 'SMYL Logistics Partner';

  CourierStage _currentStage = CourierStage.packageReceived;

  CourierStage get currentStage => _currentStage;

  @override
  CourierShipmentInfo getTrackingInfo(String trackingId) {
    return CourierShipmentInfo(
      partnerName: defaultPartner,
      trackingId: trackingId.isNotEmpty ? trackingId : defaultTrackingId,
      originHub: 'Dubai International Gateway Hub (DXB Terminal 3 Freight Station)',
      destinationAddress: 'Downtown Dubai / Abu Dhabi Residence',
      riderName: 'Mohammed S. (Verified Partner Rider)',
      riderPhone: '+971 52 881 2940',
      currentStage: _currentStage,
      estimatedDeliveryTime: DateTime.now().add(const Duration(hours: 3)),
      events: buildEventsForStage(_currentStage),
    );
  }

  @override
  CourierShipmentInfo advanceCourierStage(String trackingId) {
    switch (_currentStage) {
      case CourierStage.packageReceived:
        _currentStage = CourierStage.shipmentProcessed;
        break;
      case CourierStage.shipmentProcessed:
        _currentStage = CourierStage.outForDelivery;
        break;
      case CourierStage.outForDelivery:
        _currentStage = CourierStage.delivered;
        break;
      case CourierStage.delivered:
        _currentStage = CourierStage.packageReceived; // loop for demo testing
        break;
    }
    return getTrackingInfo(trackingId);
  }

  @override
  List<CourierTrackingEvent> buildEventsForStage(CourierStage stage) {
    final now = DateTime.now();
    final idx = stage.stepIndex;

    return [
      CourierTrackingEvent(
        id: 'cr_evt_1',
        stage: CourierStage.packageReceived,
        title: 'Package Received at Gateway Hub',
        description: 'Transferred from Arjun Reddy at DXB Airside Cargo Lounge.',
        location: 'Dubai Gateway Hub (DXB T3)',
        timestamp: now.subtract(const Duration(hours: 2)),
        isCompleted: idx >= 0,
      ),
      CourierTrackingEvent(
        id: 'cr_evt_2',
        stage: CourierStage.shipmentProcessed,
        title: 'Shipment Processed & Cleared',
        description: 'Customs cleared. Assigned to Route DXB-DOWNTOWN-04.',
        location: 'SMYL Sort Facility, Dubai',
        timestamp: now.subtract(const Duration(minutes: 75)),
        isCompleted: idx >= 1,
      ),
      CourierTrackingEvent(
        id: 'cr_evt_3',
        stage: CourierStage.outForDelivery,
        title: 'Out for Doorstep Delivery',
        description: 'Mohammed S. is on the way with your package. OTP required on delivery.',
        location: 'Downtown Dubai Corridor',
        timestamp: now.subtract(const Duration(minutes: 20)),
        isCompleted: idx >= 2,
      ),
      CourierTrackingEvent(
        id: 'cr_evt_4',
        stage: CourierStage.delivered,
        title: 'Delivered Successfully',
        description: 'Delivery verified via Receiver OTP 739104.',
        location: 'Downtown Dubai Residence',
        timestamp: now,
        isCompleted: idx >= 3,
      ),
    ];
  }
}
