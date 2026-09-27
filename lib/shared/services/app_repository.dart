import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/transaction_status.dart';
import '../models/user_model.dart';
import '../models/shipment_model.dart';
import '../models/journey_model.dart';
import '../models/transaction_model.dart';
import '../models/courier_partner_model.dart';
import '../models/claim_model.dart';
import '../models/prohibited_rule_model.dart';
import '../models/audit_log_model.dart';
import '../models/notification_item.dart';
import '../models/tracking_event_model.dart';
import 'mock_data_service.dart';
import 'payment_service.dart';
import 'courier_service.dart';

class AppRepository extends ChangeNotifier {
  late UserModel _currentUser;
  late List<JourneyModel> _journeys;
  late List<ShipmentModel> _shipments;
  late List<TransactionModel> _transactions;
  late List<CourierPartnerModel> _courierPartners;
  late List<ClaimModel> _claims;
  late List<ProhibitedRuleModel> _prohibitedRules;
  late List<AuditLogModel> _auditLogs;
  late List<NotificationItem> _notifications;
  
  final PaymentService paymentService = MockPaymentService();
  final CourierService courierService = MockCourierService();

  bool _isOnline = true;
  final List<String> _offlineSyncQueue = [];

  AppRepository() {
    _currentUser = MockDataService.currentUser;
    _journeys = List.from(MockDataService.initialJourneys);
    _shipments = List.from(MockDataService.initialShipments);
    _transactions = List.from(MockDataService.initialTransactions);
    _courierPartners = List.from(MockDataService.initialCourierPartners);
    _claims = List.from(MockDataService.initialClaims);
    _prohibitedRules = List.from(MockDataService.initialProhibitedRules);
    _auditLogs = List.from(MockDataService.initialAuditLogs);
    _notifications = List.from(MockDataService.initialNotifications);
  }

  // Getters
  UserModel get currentUser => _currentUser;
  List<JourneyModel> get journeys => List.unmodifiable(_journeys);
  List<ShipmentModel> get shipments => List.unmodifiable(_shipments);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<CourierPartnerModel> get courierPartners => List.unmodifiable(_courierPartners);
  List<ClaimModel> get claims => List.unmodifiable(_claims);
  List<ProhibitedRuleModel> get prohibitedRules => List.unmodifiable(_prohibitedRules);
  List<AuditLogModel> get auditLogs => List.unmodifiable(_auditLogs);
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  bool get isOnline => _isOnline;
  int get offlineQueueCount => _offlineSyncQueue.length;

  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  // Single Source of Truth: Master Scenario Transaction
  TransactionModel get primaryTransaction => _transactions.firstWhere(
        (t) => t.id == 'SMYL-2026-000184',
        orElse: () => _transactions.first,
      );

  ShipmentModel get primaryShipment => _shipments.firstWhere(
        (s) => s.id == 'SMYL-2026-000184',
        orElse: () => _shipments.first,
      );

  JourneyModel get primaryJourney => _journeys.firstWhere(
        (j) => j.id == 'SMYL-JRN-2026',
        orElse: () => _journeys.first,
      );

  List<TrackingEventModel> getTrackingEventsFor(String transactionId) {
    final trx = _transactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => primaryTransaction,
    );
    return MockDataService.getTrackingEvents(transactionId, trx.status);
  }

  // Demo Persona Switcher (Developer Bar)
  void switchDemoRole(UserRole newRole) {
    switch (newRole) {
      case UserRole.sender:
        _currentUser = UserModel.demoSender;
        break;
      case UserRole.traveller:
        _currentUser = UserModel.demoTraveller;
        break;
      case UserRole.receiver:
        _currentUser = UserModel.demoReceiver;
        break;
      case UserRole.admin:
        _currentUser = UserModel.demoAdmin;
        break;
      case UserRole.both:
        _currentUser = UserModel.demoSender;
        break;
    }
    notifyListeners();
  }

  // Reset Demo to Initial State
  void resetDemoScenario() {
    _currentUser = UserModel.demoSender;
    _journeys = List.from(MockDataService.initialJourneys);
    _shipments = List.from(MockDataService.initialShipments);
    _transactions = List.from(MockDataService.initialTransactions);
    _courierPartners = List.from(MockDataService.initialCourierPartners);
    _claims = List.from(MockDataService.initialClaims);
    _auditLogs = List.from(MockDataService.initialAuditLogs);
    _notifications = List.from(MockDataService.initialNotifications);
    notifyListeners();
  }

  // Connectivity Actions
  void toggleConnectivity() {
    _isOnline = !_isOnline;
    if (_isOnline && _offlineSyncQueue.isNotEmpty) {
      _offlineSyncQueue.clear();
      addNotification(
        NotificationItem(
          id: 'sync_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Offline Queue Synchronized',
          body: 'All cached transactions and verification checkpoints uploaded.',
          category: NotificationCategory.system,
          timestamp: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  // User & KYC
  void switchUserRole(UserRole newRole) {
    _currentUser = _currentUser.copyWith(role: newRole);
    notifyListeners();
  }

  void updateKycStatus(KycStatus status, {String? passportNumber, String? idNumber}) {
    final prev = _currentUser.kycStatus.label;
    _currentUser = _currentUser.copyWith(
      kycStatus: status,
      passportNumber: passportNumber ?? _currentUser.passportNumber,
      governmentIdNumber: idNumber ?? _currentUser.governmentIdNumber,
    );
    _recordAuditLog(
      action: 'User KYC Status Changed',
      prevStatus: prev,
      newStatus: status.label,
      refId: _currentUser.id,
      entityType: 'User',
      reason: 'KYC identity review updated by operations.',
    );
    notifyListeners();
  }

  // Shipment Lifecycle
  void createShipment(ShipmentModel shipment) {
    _shipments.insert(0, shipment);
    if (!_isOnline) {
      _offlineSyncQueue.add('CREATE_SHIPMENT:${shipment.id}');
    }
    _recordAuditLog(
      action: 'Shipment Created',
      prevStatus: 'NONE',
      newStatus: shipment.status.label,
      refId: shipment.id,
      entityType: 'Shipment',
      reason: 'New shipment order submitted by sender.',
    );
    notifyListeners();
  }

  // Traveller Journey Lifecycle
  void postJourney(JourneyModel journey) {
    _journeys.insert(0, journey);
    if (!_isOnline) {
      _offlineSyncQueue.add('POST_JOURNEY:${journey.id}');
    }
    _recordAuditLog(
      action: 'Journey Published',
      prevStatus: 'NONE',
      newStatus: 'ACTIVE',
      refId: journey.id,
      entityType: 'Journey',
      reason: 'Traveller listed international itinerary with ${journey.availableCapacityKg} KG capacity.',
    );
    notifyListeners();
  }

  // 1. SENDER: Request to Carry -> TRAVELLER_REQUESTED
  void requestTraveller(String transactionId, JourneyModel journey) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        journeyId: journey.id,
        travellerId: journey.travellerId,
        travellerName: journey.travellerName,
        status: TransactionStatus.travellerRequested,
        updatedAt: DateTime.now(),
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          matchedTravellerId: journey.travellerId,
          matchedTravellerName: journey.travellerName,
          status: TransactionStatus.travellerRequested,
        );
      }

      _recordAuditLog(
        action: 'Traveller Requested',
        prevStatus: 'OPEN_FOR_MATCHING',
        newStatus: 'TRAVELLER_REQUESTED',
        refId: transactionId,
        entityType: 'Transaction',
        reason: 'Lakshmi Narayana requested Arjun Reddy (EK-527) to carry 2.0 KG consignment.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Delivery Request Sent',
          body: 'Consignment request sent to Arjun Reddy for flight EK-527.',
          category: NotificationCategory.transaction,
          relatedTransactionId: transactionId,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  // 2. TRAVELLER: Accept Request -> ACCEPTED
  void acceptConsignment(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: TransactionStatus.accepted,
        updatedAt: DateTime.now(),
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          status: TransactionStatus.accepted,
        );
      }

      _recordAuditLog(
        action: 'Consignment Accepted by Traveller',
        prevStatus: 'TRAVELLER_REQUESTED',
        newStatus: 'ACCEPTED',
        refId: transactionId,
        entityType: 'Transaction',
        reason: 'Arjun Reddy accepted delivery request for shipment $transactionId.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_1',
          title: 'Arjun accepted your delivery request.',
          body: 'Please proceed with secure escrow payment of ₹1,850 to lock your booking.',
          category: NotificationCategory.transaction,
          relatedTransactionId: transactionId,
          timestamp: DateTime.now(),
        ),
      );

      addNotification(
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_2',
          title: 'Delivery request accepted.',
          body: 'Awaiting sender escrow payment before airport handover.',
          category: NotificationCategory.transaction,
          relatedTransactionId: transactionId,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  // 2b. TRAVELLER: Decline Request -> Revert to OPEN_FOR_MATCHING
  void rejectConsignment(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        travellerId: null,
        travellerName: null,
        status: TransactionStatus.openForMatching,
        updatedAt: DateTime.now(),
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          matchedTravellerId: null,
          matchedTravellerName: null,
          status: TransactionStatus.openForMatching,
        );
      }

      _recordAuditLog(
        action: 'Consignment Declined by Traveller',
        prevStatus: 'TRAVELLER_REQUESTED',
        newStatus: 'OPEN_FOR_MATCHING',
        refId: transactionId,
        entityType: 'Transaction',
        reason: 'Traveller unavailable. Consignment re-opened for matching.',
      );

      notifyListeners();
    }
  }

  // 3. SENDER: Process Escrow Payment -> PAYMENT_CONFIRMED
  void processPayment(String transactionId, String paymentMethod) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      const paymentRef = 'SMYL-PAY-2026-008721';
      final total = _transactions[tIndex].totalAmount;
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: TransactionStatus.paymentConfirmed,
        paymentStatus: PaymentStatus.authorizedEscrow,
        paymentReference: paymentRef,
        updatedAt: DateTime.now(),
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          status: TransactionStatus.paymentConfirmed,
        );
      }

      _recordAuditLog(
        action: 'Escrow Payment Confirmed',
        prevStatus: 'ACCEPTED',
        newStatus: 'PAYMENT_CONFIRMED',
        refId: transactionId,
        entityType: 'Financial Gateway',
        reason: 'Authorized payment of ₹${total.toInt()} via $paymentMethod. Ref: $paymentRef.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_pay1',
          title: 'Payment Confirmed: Ref $paymentRef',
          body: 'Funds of ₹${total.toInt()} held in SMYL Escrow. Payment released only upon OTP delivery verification.',
          category: NotificationCategory.payout,
          relatedTransactionId: transactionId,
          timestamp: DateTime.now(),
        ),
      );

      addNotification(
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}_pay2',
          title: 'Payment Secured for Trip',
          body: 'Lakshmi Narayana authorized ₹${total.toInt()}. Proceed to airport handover at Departure Gate 4.',
          category: NotificationCategory.payout,
          relatedTransactionId: transactionId,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  // Realistic UPI Payment execution
  Future<PaymentReceipt> payWithUpi({
    required String transactionId,
    required String upiId,
    void Function(PaymentGatewayStage stage, String message)? onProgress,
  }) async {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    final tx = tIndex != -1 ? _transactions[tIndex] : primaryTransaction;
    final receipt = await paymentService.processUpiPayment(
      transactionId: transactionId,
      upiId: upiId,
      totalAmount: tx.totalAmount,
      deliveryCharge: tx.travellerPayout,
      platformFee: tx.platformFee,
      courierFee: tx.courierFee,
      senderName: tx.senderName,
      onProgress: onProgress,
    );
    processPayment(transactionId, 'UPI ($upiId)');
    return receipt;
  }

  // Realistic QR Payment confirmation
  Future<PaymentReceipt> payWithQr({
    required String transactionId,
  }) async {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    final tx = tIndex != -1 ? _transactions[tIndex] : primaryTransaction;
    final receipt = await paymentService.confirmQrPayment(
      transactionId: transactionId,
      totalAmount: tx.totalAmount,
      deliveryCharge: tx.travellerPayout,
      platformFee: tx.platformFee,
      courierFee: tx.courierFee,
      senderName: tx.senderName,
    );
    processPayment(transactionId, 'UPI Dynamic QR');
    return receipt;
  }

  // Retrieve Digital Payment Receipt for Transaction
  PaymentReceipt getPaymentReceipt(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    final tx = tIndex != -1 ? _transactions[tIndex] : primaryTransaction;
    return paymentService.generateReceiptForTransaction(
      transactionId: transactionId,
      totalAmount: tx.totalAmount,
      deliveryCharge: tx.travellerPayout,
      platformFee: tx.platformFee,
      courierFee: tx.courierFee,
      senderName: tx.senderName,
      paymentRef: tx.paymentReference,
    );
  }

  // Retrieve Courier Shipment Info
  CourierShipmentInfo getCourierInfo(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    final trackingId = tIndex != -1 && _transactions[tIndex].courierTrackingId != null
        ? _transactions[tIndex].courierTrackingId!
        : 'SML-CP-829104';
    return courierService.getTrackingInfo(trackingId);
  }

  // Step Courier Tracking Stage
  CourierShipmentInfo advanceCourierTracking(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    final trackingId = tIndex != -1 && _transactions[tIndex].courierTrackingId != null
        ? _transactions[tIndex].courierTrackingId!
        : 'SML-CP-829104';
    final updatedInfo = courierService.advanceCourierStage(trackingId);

    if (tIndex != -1) {
      if (updatedInfo.currentStage == CourierStage.delivered) {
        _transactions[tIndex] = _transactions[tIndex].copyWith(
          status: TransactionStatus.delivered,
          deliveryTime: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else if (updatedInfo.currentStage == CourierStage.outForDelivery) {
        _transactions[tIndex] = _transactions[tIndex].copyWith(
          status: TransactionStatus.outForDelivery,
          updatedAt: DateTime.now(),
        );
      } else {
        _transactions[tIndex] = _transactions[tIndex].copyWith(
          status: TransactionStatus.withCourierPartner,
          updatedAt: DateTime.now(),
        );
      }
    }
    notifyListeners();
    return updatedInfo;
  }

  // 4. PREPARE HANDOVER -> READY_FOR_HANDOVER
  void prepareHandover(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: TransactionStatus.readyForHandover,
        updatedAt: DateTime.now(),
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          status: TransactionStatus.readyForHandover,
        );
      }

      _recordAuditLog(
        action: 'Handover Initiated',
        prevStatus: 'PAYMENT_CONFIRMED',
        newStatus: 'READY_FOR_HANDOVER',
        refId: transactionId,
        entityType: 'Handover',
        reason: 'Handover protocol active at Hyderabad Airport Departure Gate 4.',
      );

      notifyListeners();
    }
  }

  // 5. TRAVELLER: Verify Origin Handover OTP -> HANDED_TO_TRAVELLER
  bool verifyOriginHandoverOtp(String transactionId, String enteredOtp) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex == -1) return false;

    final trx = _transactions[tIndex];
    if (trx.originHandoverOtp == enteredOtp.trim()) {
      final now = DateTime.now();
      _transactions[tIndex] = trx.copyWith(
        status: TransactionStatus.handedToTraveller,
        handoverTime: now,
        updatedAt: now,
      );

      final sIndex = _shipments.indexWhere((s) => s.id == trx.shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          status: TransactionStatus.handedToTraveller,
        );
      }

      _recordAuditLog(
        action: 'Origin Handover Verified via OTP',
        prevStatus: trx.status.label,
        newStatus: 'HANDED_TO_TRAVELLER',
        refId: transactionId,
        entityType: 'Handover',
        reason: 'Physical inspection completed; OTP 482913 verified by Arjun Reddy.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${now.millisecondsSinceEpoch}_hnd1',
          title: 'Handover Confirmed via OTP',
          body: 'Consignment successfully handed over to Arjun Reddy at Hyderabad Airport.',
          category: NotificationCategory.security,
          relatedTransactionId: transactionId,
          timestamp: now,
        ),
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  // 6. TRAVELLER: Start Journey / Departed -> IN_TRANSIT
  void startJourney(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      final now = DateTime.now();
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: TransactionStatus.inTransit,
        departureTime: now,
        updatedAt: now,
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(status: TransactionStatus.inTransit);
      }

      _recordAuditLog(
        action: 'Flight Departed',
        prevStatus: 'HANDED_TO_TRAVELLER',
        newStatus: 'IN_TRANSIT',
        refId: transactionId,
        entityType: 'Flight Carrier',
        reason: 'Flight EK-527 departed Rajiv Gandhi Int\'l Airport en route to DXB.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${now.millisecondsSinceEpoch}_trn',
          title: 'Flight EK-527 In Transit',
          body: 'Your shipment is in flight to Dubai International Airport.',
          category: NotificationCategory.transaction,
          relatedTransactionId: transactionId,
          timestamp: now,
        ),
      );

      notifyListeners();
    }
  }

  // 7. TRAVELLER: Arrived at Destination -> ARRIVED_AT_DESTINATION
  void arriveAtDestination(String transactionId) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      final now = DateTime.now();
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: TransactionStatus.arrivedAtDestination,
        arrivalTime: now,
        updatedAt: now,
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(status: TransactionStatus.arrivedAtDestination);
      }

      _recordAuditLog(
        action: 'Flight Arrived at Destination Airport',
        prevStatus: 'IN_TRANSIT',
        newStatus: 'ARRIVED_AT_DESTINATION',
        refId: transactionId,
        entityType: 'Flight Carrier',
        reason: 'Flight EK-527 landed at Dubai International Terminal 3.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${now.millisecondsSinceEpoch}_arv',
          title: 'Arrived in Dubai!',
          body: 'Consignment has safely landed in Dubai. Ready for delivery to Rahul Kumar.',
          category: NotificationCategory.transaction,
          relatedTransactionId: transactionId,
          timestamp: now,
        ),
      );

      notifyListeners();
    }
  }

  // 8. RECEIVER: Confirm Delivery with Secret OTP -> DELIVERED & COMPLETED
  bool confirmDelivery(String transactionId, String enteredOtp) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex == -1) return false;

    final trx = _transactions[tIndex];
    if (trx.destinationHandoverOtp == enteredOtp.trim()) {
      final now = DateTime.now();
      _transactions[tIndex] = trx.copyWith(
        status: TransactionStatus.completed,
        paymentStatus: PaymentStatus.releasedToTraveller,
        deliveryTime: now,
        updatedAt: now,
      );

      final sIndex = _shipments.indexWhere((s) => s.id == trx.shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(
          status: TransactionStatus.completed,
        );
      }

      _recordAuditLog(
        action: 'Delivery Confirmed via OTP & Escrow Settled',
        prevStatus: trx.status.label,
        newStatus: 'COMPLETED',
        refId: transactionId,
        entityType: 'Delivery Settlement',
        reason: 'Rahul Kumar verified delivery OTP 739104. ₹1,500 escrow payout released to Arjun Reddy.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${now.millisecondsSinceEpoch}_del1',
          title: 'Delivery Confirmed & Settled!',
          body: 'Rahul Kumar received the package. Escrow payout of ₹1,500 has been released to Arjun Reddy.',
          category: NotificationCategory.payout,
          relatedTransactionId: transactionId,
          timestamp: now,
        ),
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  // Alias for backward compatibility with handover screens & tests
  bool verifyDeliveryOtp(String transactionId, String enteredOtp) => confirmDelivery(transactionId, enteredOtp);

  // Fallback Matching & Booking (kept for custom shipments)
  TransactionModel createTransactionFromMatch({
    required ShipmentModel shipment,
    required JourneyModel journey,
  }) {
    final transactionId = 'SMYL-TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newTransaction = TransactionModel(
      id: transactionId,
      shipmentId: shipment.id,
      journeyId: journey.id,
      senderId: shipment.senderId,
      senderName: shipment.senderName,
      travellerId: journey.travellerId,
      travellerName: journey.travellerName,
      receiverName: shipment.receiverName,
      receiverPhone: shipment.receiverPhone,
      originCity: shipment.pickupCity,
      originCountry: shipment.pickupCountry,
      originAirportCode: journey.originAirportCode,
      destCity: shipment.destCity,
      destCountry: shipment.destCountry,
      destAirportCode: journey.destAirportCode,
      itemCategory: shipment.itemCategory,
      itemDescription: shipment.itemDescription,
      weightKg: shipment.weightKg,
      status: TransactionStatus.accepted,
      paymentStatus: PaymentStatus.authorizedEscrow,
      totalAmount: shipment.estimatedCost,
      travellerPayout: shipment.travellerPayout,
      platformFee: shipment.platformFee,
      courierFee: shipment.courierFee,
      originHandoverOtp: shipment.originOtp,
      destinationHandoverOtp: shipment.deliveryOtp,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _transactions.insert(0, newTransaction);
    
    final sIndex = _shipments.indexWhere((s) => s.id == shipment.id);
    if (sIndex != -1) {
      _shipments[sIndex] = _shipments[sIndex].copyWith(
        matchedTravellerId: journey.travellerId,
        matchedTravellerName: journey.travellerName,
        status: TransactionStatus.accepted,
      );
    }

    _recordAuditLog(
      action: 'Match Accepted & Escrow Authorized',
      prevStatus: 'OPEN_FOR_MATCHING',
      newStatus: 'ACCEPTED',
      refId: transactionId,
      entityType: 'Transaction',
      reason: 'Sender selected traveller ${journey.travellerName}; escrow holds funds.',
    );

    notifyListeners();
    return newTransaction;
  }

  // Update Status from Flight / In-Transit / Courier
  void updateTransactionStatus(String transactionId, TransactionStatus newStatus) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      final prev = _transactions[tIndex].status.label;
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      final sIndex = _shipments.indexWhere((s) => s.id == _transactions[tIndex].shipmentId);
      if (sIndex != -1) {
        _shipments[sIndex] = _shipments[sIndex].copyWith(status: newStatus);
      }

      _recordAuditLog(
        action: 'Transaction Status Changed',
        prevStatus: prev,
        newStatus: newStatus.label,
        refId: transactionId,
        entityType: 'Transaction',
        reason: 'Operational status update triggered.',
      );

      notifyListeners();
    }
  }


  // Assign Courier Partner
  void assignCourierPartner({
    required String transactionId,
    required CourierPartnerModel courier,
    required String trackingId,
  }) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        courierPartnerId: courier.id,
        courierPartnerName: courier.name,
        courierTrackingId: trackingId,
        status: TransactionStatus.withCourierPartner,
        updatedAt: DateTime.now(),
      );

      _recordAuditLog(
        action: 'Courier Partner Assigned',
        prevStatus: 'ARRIVED AT DESTINATION',
        newStatus: 'WITH COURIER PARTNER',
        refId: transactionId,
        entityType: 'Courier Logistics',
        reason: 'Handoff to ${courier.name} with partner tracking $trackingId.',
      );

      addNotification(
        NotificationItem(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Handed to Courier Partner',
          body: '${courier.name} picked up shipment (Tracking: $trackingId).',
          category: NotificationCategory.transaction,
          relatedTransactionId: transactionId,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  // Admin Place on Hold
  void toggleTransactionHold(String transactionId, bool placeOnHold, String reason) {
    final tIndex = _transactions.indexWhere((t) => t.id == transactionId);
    if (tIndex != -1) {
      final prev = _transactions[tIndex].status.label;
      final newStatus = placeOnHold ? TransactionStatus.onHold : TransactionStatus.inTransit;
      _transactions[tIndex] = _transactions[tIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      _recordAuditLog(
        action: placeOnHold ? 'Transaction Placed On Hold' : 'Transaction Hold Released',
        prevStatus: prev,
        newStatus: newStatus.label,
        refId: transactionId,
        entityType: 'Admin Hold',
        reason: reason,
      );

      notifyListeners();
    }
  }

  // Claims
  void fileClaim(ClaimModel claim) {
    _claims.insert(0, claim);
    _recordAuditLog(
      action: 'Claim Submitted',
      prevStatus: 'NONE',
      newStatus: claim.status.label,
      refId: claim.id,
      entityType: 'Claims',
      reason: 'User submitted ${claim.issueType.label} claim.',
    );
    notifyListeners();
  }

  void updateClaimStatus(String claimId, ClaimStatus status, String notes) {
    final cIndex = _claims.indexWhere((c) => c.id == claimId);
    if (cIndex != -1) {
      final prev = _claims[cIndex].status.label;
      _claims[cIndex] = _claims[cIndex].copyWith(
        status: status,
        resolutionSummary: notes,
      );

      _recordAuditLog(
        action: 'Claim Status Updated',
        prevStatus: prev,
        newStatus: status.label,
        refId: claimId,
        entityType: 'Claims',
        reason: notes,
      );

      notifyListeners();
    }
  }

  // Notifications
  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void _recordAuditLog({
    required String action,
    required String prevStatus,
    required String newStatus,
    required String refId,
    required String entityType,
    required String reason,
  }) {
    final log = AuditLogModel(
      id: 'LOG-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      adminId: _currentUser.id,
      adminName: _currentUser.role == UserRole.admin ? 'Super Admin' : _currentUser.name,
      action: action,
      previousStatus: prevStatus,
      newStatus: newStatus,
      referenceId: refId,
      entityType: entityType,
      reason: reason,
      timestamp: DateTime.now(),
    );
    _auditLogs.insert(0, log);
  }
}

// Riverpod Provider
final appRepositoryProvider = ChangeNotifierProvider<AppRepository>((ref) {
  return AppRepository();
});
