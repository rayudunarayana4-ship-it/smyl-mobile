import 'package:flutter_test/flutter_test.dart';
import 'package:smyl_mobile/shared/models/transaction_status.dart';
import 'package:smyl_mobile/shared/models/transaction_model.dart';
import 'package:smyl_mobile/shared/models/user_model.dart';
import 'package:smyl_mobile/shared/services/app_repository.dart';
import 'package:smyl_mobile/shared/services/courier_service.dart';

void main() {
  group('SMYL Global Business Logic & State Machine Tests', () {
    test('Central Status Extension properties', () {
      expect(TransactionStatus.created.label, 'CREATED');
      expect(TransactionStatus.inTransit.label, 'IN TRANSIT');
      expect(TransactionStatus.delivered.label, 'DELIVERED');
      expect(TransactionStatus.onHold.label, 'ON HOLD');
      expect(TransactionStatus.onHold.isException, isTrue);
      expect(TransactionStatus.inTransit.isException, isFalse);
    });

    test('Origin Handover OTP verification and state transition', () {
      final repo = AppRepository();
      final initialTx = repo.transactions.first;

      // Ensure initial transaction has valid OTP
      expect(initialTx.originHandoverOtp.length, 6);

      // Incorrect OTP should fail
      final failedAttempt = repo.verifyOriginHandoverOtp(initialTx.id, '000000');
      expect(failedAttempt, isFalse);

      // Correct OTP should succeed and transition state to handedToTraveller
      final success = repo.verifyOriginHandoverOtp(
        initialTx.id,
        initialTx.originHandoverOtp,
      );
      expect(success, isTrue);

      final updatedTx = repo.transactions.firstWhere((t) => t.id == initialTx.id);
      expect(updatedTx.status, TransactionStatus.handedToTraveller);
    });

    test('Delivery Handover OTP releases escrow payout', () {
      final repo = AppRepository();
      final initialTx = repo.transactions.first;

      final success = repo.verifyDeliveryOtp(
        initialTx.id,
        initialTx.destinationHandoverOtp,
      );
      expect(success, isTrue);

      final updatedTx = repo.transactions.firstWhere((t) => t.id == initialTx.id);
      expect(updatedTx.status, TransactionStatus.completed);
      expect(updatedTx.paymentStatus, PaymentStatus.releasedToTraveller);
    });

    test('Admin placing hold and releasing hold records audit log', () {
      final repo = AppRepository();
      final initialLogCount = repo.auditLogs.length;
      final targetTx = repo.transactions.first;

      repo.toggleTransactionHold(targetTx.id, true, 'Customs inspection hold');
      expect(repo.auditLogs.length, initialLogCount + 1);
      expect(repo.auditLogs.first.action, 'Transaction Placed On Hold');

      final onHoldTx = repo.transactions.firstWhere((t) => t.id == targetTx.id);
      expect(onHoldTx.status, TransactionStatus.onHold);

      repo.toggleTransactionHold(targetTx.id, false, 'Clearance granted');
      expect(repo.auditLogs.length, initialLogCount + 2);
      expect(repo.auditLogs.first.action, 'Transaction Hold Released');
    });

    test('Role switching updates permissions dynamically', () {
      final repo = AppRepository();
      expect(repo.currentUser.role, UserRole.sender);

      repo.switchDemoRole(UserRole.traveller);
      expect(repo.currentUser.role, UserRole.traveller);

      repo.switchDemoRole(UserRole.receiver);
      expect(repo.currentUser.role, UserRole.receiver);

      repo.switchDemoRole(UserRole.admin);
      expect(repo.currentUser.role, UserRole.admin);

      repo.switchDemoRole(UserRole.sender);
      expect(repo.currentUser.role, UserRole.sender);
    });

    test('SMYL-2026-000184 Full 15-Step Production Workflow Lifecycle', () {
      final repo = AppRepository();
      final tx = repo.primaryTransaction;

      // 1. Initial State
      expect(tx.id, 'SMYL-2026-000184');
      expect(tx.status, TransactionStatus.openForMatching);
      expect(tx.senderName, 'Lakshmi Narayana');
      expect(tx.receiverName, 'Rahul Kumar');
      expect(tx.originHandoverOtp, '482913');
      expect(tx.destinationHandoverOtp, '739104');

      // 2. Sender requests Traveller (Arjun Reddy)
      repo.requestTraveller(tx.id, repo.primaryJourney);
      expect(repo.primaryTransaction.status, TransactionStatus.travellerRequested);

      // 3. Traveller accepts
      repo.acceptConsignment(tx.id);
      expect(repo.primaryTransaction.status, TransactionStatus.accepted);

      // 4. Sender pays escrow
      repo.processPayment(tx.id, 'MOCK-TXN-SUCCESS');
      expect(repo.primaryTransaction.status, TransactionStatus.paymentConfirmed);
      expect(repo.primaryTransaction.paymentStatus, PaymentStatus.authorizedEscrow);

      // 5. Traveller sets Ready for Handover
      repo.prepareHandover(tx.id);
      expect(repo.primaryTransaction.status, TransactionStatus.readyForHandover);

      // 6. Origin Handover OTP verified (482913)
      final wrongOriginOtp = repo.verifyOriginHandoverOtp(tx.id, '111111');
      expect(wrongOriginOtp, isFalse);
      final rightOriginOtp = repo.verifyOriginHandoverOtp(tx.id, '482913');
      expect(rightOriginOtp, isTrue);
      expect(repo.primaryTransaction.status, TransactionStatus.handedToTraveller);

      // 7. Journey Started -> In Transit
      repo.startJourney(tx.id);
      expect(repo.primaryTransaction.status, TransactionStatus.inTransit);

      // 8. Flight lands -> Arrived at Destination
      repo.arriveAtDestination(tx.id);
      expect(repo.primaryTransaction.status, TransactionStatus.arrivedAtDestination);

      // 9. Delivery OTP verified (739104) -> Completed & Escrow Released
      final wrongDelOtp = repo.confirmDelivery(tx.id, '999999');
      expect(wrongDelOtp, isFalse);
      final rightDelOtp = repo.confirmDelivery(tx.id, '739104');
      expect(rightDelOtp, isTrue);
      expect(repo.primaryTransaction.status, TransactionStatus.completed);
      expect(repo.primaryTransaction.paymentStatus, PaymentStatus.releasedToTraveller);

      // 10. Reset returns back to initial pristine state
      repo.resetDemoScenario();
      expect(repo.primaryTransaction.status, TransactionStatus.openForMatching);
    });

    test('Customer Friendly Status Translation (Golden UX Rule)', () {
      expect(TransactionStatus.openForMatching.customerStatusText,
          'Finding Verified Travellers');
      expect(TransactionStatus.travellerRequested.customerStatusText,
          'Waiting for Traveller');
      expect(TransactionStatus.paymentConfirmed.customerStatusText,
          'Payment Confirmed');
      expect(TransactionStatus.readyForHandover.customerStatusText,
          'Ready for Handover');
      expect(TransactionStatus.inTransit.customerStatusText,
          'In Transit');
      expect(TransactionStatus.withCourierPartner.customerStatusText,
          'Handed to Delivery Partner');
      expect(TransactionStatus.completed.customerStatusText,
          'Delivered');
      expect(TransactionStatus.completed.customerSubtext,
          contains('Delivery confirmed with OTP'));
    });

    test('PaymentService UPI ID validation & receipt calculation', () async {
      final repo = AppRepository();
      final paymentService = repo.paymentService;

      // Validate UPI VPAs
      expect(paymentService.validateUpiId('lakshmi.narayana@okaxis'), isTrue);
      expect(paymentService.validateUpiId('user@upi'), isTrue);
      expect(paymentService.validateUpiId('invalid-upi'), isFalse);
      expect(paymentService.validateUpiId(''), isFalse);

      // Verify Pricing Breakdown: 1,800 + 180 + 250 = 2,230
      final tx = repo.primaryTransaction;
      expect(tx.travellerPayout, 1800.0);
      expect(tx.platformFee, 180.0);
      expect(tx.courierFee, 250.0);
      expect(tx.totalAmount, 2230.0);

      // Execute UPI Payment
      final receipt = await repo.payWithUpi(
        transactionId: tx.id,
        upiId: 'lakshmi.narayana@okaxis',
      );
      expect(receipt.paymentReference, 'SMYL-PAY-2026-008721');
      expect(receipt.totalAmount, 2230.0);
      expect(receipt.deliveryCharge, 1800.0);
      expect(receipt.platformFee, 180.0);
      expect(receipt.courierFee, 250.0);
      expect(repo.primaryTransaction.status, TransactionStatus.paymentConfirmed);
      expect(repo.primaryTransaction.paymentStatus, PaymentStatus.authorizedEscrow);
    });

    test('CourierService multi-stage tracking & progression (SML-CP-829104)', () {
      final repo = AppRepository();
      final tx = repo.primaryTransaction;

      // Initial courier info
      final info = repo.getCourierInfo(tx.id);
      expect(info.trackingId, 'SML-CP-829104');
      expect(info.partnerName, 'SMYL Logistics Partner');
      expect(info.events.length, 4);

      // Advance stage: packageReceived -> shipmentProcessed
      final stage2 = repo.advanceCourierTracking(tx.id);
      expect(stage2.currentStage.stepIndex, 1);
      expect(repo.primaryTransaction.status, TransactionStatus.withCourierPartner);

      // Advance stage: shipmentProcessed -> outForDelivery
      final stage3 = repo.advanceCourierTracking(tx.id);
      expect(stage3.currentStage.stepIndex, 2);
      expect(repo.primaryTransaction.status, TransactionStatus.outForDelivery);

      // Advance stage: outForDelivery -> delivered
      final stage4 = repo.advanceCourierTracking(tx.id);
      expect(stage4.currentStage.stepIndex, 3);
      expect(repo.primaryTransaction.status, TransactionStatus.delivered);
    });
  });
}
