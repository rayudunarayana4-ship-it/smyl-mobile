import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum TransactionStatus {
  // Standard Lifecycle
  draft,
  created,
  openForMatching,
  travellerRequested,
  accepted,
  paymentConfirmed,
  readyForHandover,
  handedToTraveller,
  inTransit,
  arrivedAtDestination,
  withCourierPartner,
  outForDelivery,
  delivered,
  completed,

  // Exceptions
  cancelled,
  onHold,
  exception,
  claimOpen,
  disputed,
  failed,
  refunded,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.draft:
        return 'DRAFT';
      case TransactionStatus.created:
        return 'CREATED';
      case TransactionStatus.openForMatching:
        return 'OPEN FOR MATCHING';
      case TransactionStatus.travellerRequested:
        return 'TRAVELLER REQUESTED';
      case TransactionStatus.accepted:
        return 'ACCEPTED';
      case TransactionStatus.paymentConfirmed:
        return 'PAYMENT CONFIRMED';
      case TransactionStatus.readyForHandover:
        return 'READY FOR HANDOVER';
      case TransactionStatus.handedToTraveller:
        return 'HANDED TO TRAVELLER';
      case TransactionStatus.inTransit:
        return 'IN TRANSIT';
      case TransactionStatus.arrivedAtDestination:
        return 'ARRIVED AT DESTINATION';
      case TransactionStatus.withCourierPartner:
        return 'WITH COURIER PARTNER';
      case TransactionStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case TransactionStatus.delivered:
        return 'DELIVERED';
      case TransactionStatus.completed:
        return 'COMPLETED';
      case TransactionStatus.cancelled:
        return 'CANCELLED';
      case TransactionStatus.onHold:
        return 'ON HOLD';
      case TransactionStatus.exception:
        return 'EXCEPTION';
      case TransactionStatus.claimOpen:
        return 'CLAIM OPEN';
      case TransactionStatus.disputed:
        return 'DISPUTED';
      case TransactionStatus.failed:
        return 'FAILED';
      case TransactionStatus.refunded:
        return 'REFUNDED';
    }
  }

  bool get isException {
    switch (this) {
      case TransactionStatus.cancelled:
      case TransactionStatus.onHold:
      case TransactionStatus.exception:
      case TransactionStatus.claimOpen:
      case TransactionStatus.disputed:
      case TransactionStatus.failed:
      case TransactionStatus.refunded:
        return true;
      default:
        return false;
    }
  }

  Color get color => statusColor;
  Color get statusColor {
    switch (this) {
      case TransactionStatus.draft:
      case TransactionStatus.created:
        return AppColors.slateLight;
      case TransactionStatus.openForMatching:
      case TransactionStatus.travellerRequested:
        return AppColors.champagneSand;
      case TransactionStatus.accepted:
      case TransactionStatus.paymentConfirmed:
        return AppColors.auroraTeal;
      case TransactionStatus.readyForHandover:
      case TransactionStatus.handedToTraveller:
      case TransactionStatus.inTransit:
      case TransactionStatus.arrivedAtDestination:
      case TransactionStatus.withCourierPartner:
      case TransactionStatus.outForDelivery:
        return AppColors.electricCyan;
      case TransactionStatus.delivered:
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.onHold:
      case TransactionStatus.claimOpen:
      case TransactionStatus.disputed:
        return AppColors.warning;
      case TransactionStatus.cancelled:
      case TransactionStatus.exception:
      case TransactionStatus.failed:
      case TransactionStatus.refunded:
        return AppColors.danger;
    }
  }

  int get standardProgressIndex {
    switch (this) {
      case TransactionStatus.created:
      case TransactionStatus.openForMatching:
        return 0;
      case TransactionStatus.travellerRequested:
        return 1;
      case TransactionStatus.accepted:
        return 2;
      case TransactionStatus.paymentConfirmed:
        return 3;
      case TransactionStatus.readyForHandover:
        return 4;
      case TransactionStatus.handedToTraveller:
        return 5;
      case TransactionStatus.inTransit:
        return 6;
      case TransactionStatus.arrivedAtDestination:
        return 7;
      case TransactionStatus.withCourierPartner:
      case TransactionStatus.outForDelivery:
        return 8;
      case TransactionStatus.delivered:
        return 9;
      case TransactionStatus.completed:
        return 10;
      default:
        return 0;
    }
  }

  // Centralized State Machine Validation
  bool canTransitionTo(TransactionStatus target) {
    if (this == target) return true;
    if (target == TransactionStatus.onHold || target == TransactionStatus.claimOpen || target == TransactionStatus.disputed || target == TransactionStatus.cancelled) {
      return true; // Exceptions can be entered from any active state
    }
    if (this == TransactionStatus.onHold) {
      return true; // Can resume from onHold upon admin release
    }

    switch (this) {
      case TransactionStatus.draft:
        return target == TransactionStatus.created;
      case TransactionStatus.created:
        return target == TransactionStatus.openForMatching;
      case TransactionStatus.openForMatching:
        return target == TransactionStatus.travellerRequested;
      case TransactionStatus.travellerRequested:
        return target == TransactionStatus.accepted || target == TransactionStatus.openForMatching;
      case TransactionStatus.accepted:
        return target == TransactionStatus.paymentConfirmed;
      case TransactionStatus.paymentConfirmed:
        return target == TransactionStatus.readyForHandover;
      case TransactionStatus.readyForHandover:
        return target == TransactionStatus.handedToTraveller;
      case TransactionStatus.handedToTraveller:
        return target == TransactionStatus.inTransit;
      case TransactionStatus.inTransit:
        return target == TransactionStatus.arrivedAtDestination;
      case TransactionStatus.arrivedAtDestination:
        return target == TransactionStatus.withCourierPartner || target == TransactionStatus.delivered;
      case TransactionStatus.withCourierPartner:
        return target == TransactionStatus.outForDelivery;
      case TransactionStatus.outForDelivery:
        return target == TransactionStatus.delivered;
      case TransactionStatus.delivered:
        return target == TransactionStatus.completed;
      case TransactionStatus.claimOpen:
      case TransactionStatus.disputed:
        return target == TransactionStatus.completed || target == TransactionStatus.refunded;
      default:
        return false;
    }
  }

  // Role-Specific Status Display (Single Source of Truth)
  String get senderStatusLabel {
    switch (this) {
      case TransactionStatus.draft:
      case TransactionStatus.created:
        return 'SHIPMENT CREATED';
      case TransactionStatus.openForMatching:
        return 'LOOKING FOR TRAVELLER';
      case TransactionStatus.travellerRequested:
        return 'WAITING FOR ARJUN TO ACCEPT';
      case TransactionStatus.accepted:
        return 'ARJUN ACCEPTED — PAYMENT REQUIRED';
      case TransactionStatus.paymentConfirmed:
        return 'PAYMENT CONFIRMED (ESCROW HELD)';
      case TransactionStatus.readyForHandover:
        return 'READY FOR AIRPORT HANDOVER';
      case TransactionStatus.handedToTraveller:
        return 'HANDED TO ARJUN';
      case TransactionStatus.inTransit:
        return 'IN FLIGHT (HYD → DXB)';
      case TransactionStatus.arrivedAtDestination:
        return 'ARRIVED AT DUBAI (DXB)';
      case TransactionStatus.withCourierPartner:
      case TransactionStatus.outForDelivery:
        return 'ONWARD COURIER DELIVERY';
      case TransactionStatus.delivered:
        return 'DELIVERED TO RAHUL KUMAR';
      case TransactionStatus.completed:
        return 'COMPLETED & ESCROW RELEASED';
      case TransactionStatus.onHold:
        return 'TRANSACTION ON HOLD';
      case TransactionStatus.claimOpen:
        return 'DISPUTE OPEN (ESCROW FROZEN)';
      default:
        return label;
    }
  }

  String get travellerStatusLabel {
    switch (this) {
      case TransactionStatus.openForMatching:
        return 'AVAILABLE REQUEST';
      case TransactionStatus.travellerRequested:
        return 'NEW CONSIGNMENT REQUEST';
      case TransactionStatus.accepted:
        return 'ACCEPTED — AWAITING SENDER PAYMENT';
      case TransactionStatus.paymentConfirmed:
        return 'PAYMENT SECURED IN ESCROW';
      case TransactionStatus.readyForHandover:
        return 'READY FOR AIRPORT RECEIPT';
      case TransactionStatus.handedToTraveller:
        return 'PARCEL IN POSSESSION';
      case TransactionStatus.inTransit:
        return 'IN TRANSIT (FLIGHT EK-527)';
      case TransactionStatus.arrivedAtDestination:
        return 'ARRIVED AT DUBAI AIRPORT';
      case TransactionStatus.withCourierPartner:
      case TransactionStatus.outForDelivery:
        return 'HANDED OVER TO COURIER';
      case TransactionStatus.delivered:
        return 'DELIVERY CONFIRMED';
      case TransactionStatus.completed:
        return 'PAYOUT RELEASED (₹1,500)';
      case TransactionStatus.onHold:
        return 'ESCROW HELD BY ADMIN';
      case TransactionStatus.claimOpen:
        return 'DISPUTE UNDER INVESTIGATION';
      default:
        return label;
    }
  }

  String get receiverStatusLabel {
    switch (this) {
      case TransactionStatus.openForMatching:
      case TransactionStatus.travellerRequested:
      case TransactionStatus.accepted:
      case TransactionStatus.paymentConfirmed:
        return 'SHIPMENT SCHEDULED';
      case TransactionStatus.readyForHandover:
      case TransactionStatus.handedToTraveller:
        return 'HANDED TO TRAVELLER';
      case TransactionStatus.inTransit:
        return 'YOUR ITEM IS ON THE WAY';
      case TransactionStatus.arrivedAtDestination:
        return 'ARRIVED AT DESTINATION';
      case TransactionStatus.withCourierPartner:
      case TransactionStatus.outForDelivery:
        return 'OUT FOR FINAL DELIVERY';
      case TransactionStatus.delivered:
      case TransactionStatus.completed:
        return 'DELIVERED & SIGNED';
      default:
        return label;
    }
  }

  String get adminStatusLabel => label;

  String get customerStatusText {
    switch (this) {
      case TransactionStatus.draft:
      case TransactionStatus.created:
        return 'Request Created';
      case TransactionStatus.openForMatching:
        return 'Finding Verified Travellers';
      case TransactionStatus.travellerRequested:
        return 'Waiting for Traveller';
      case TransactionStatus.accepted:
        return 'Traveller Accepted';
      case TransactionStatus.paymentConfirmed:
        return 'Payment Confirmed';
      case TransactionStatus.readyForHandover:
        return 'Ready for Handover';
      case TransactionStatus.handedToTraveller:
        return 'With Traveller';
      case TransactionStatus.inTransit:
        return 'In Transit';
      case TransactionStatus.arrivedAtDestination:
        return 'Arrived at Destination';
      case TransactionStatus.withCourierPartner:
        return 'Handed to Delivery Partner';
      case TransactionStatus.outForDelivery:
        return 'Out for Delivery';
      case TransactionStatus.delivered:
      case TransactionStatus.completed:
        return 'Delivered';
      case TransactionStatus.onHold:
        return 'Temporarily on Hold';
      case TransactionStatus.cancelled:
        return 'Cancelled';
      case TransactionStatus.disputed:
      case TransactionStatus.claimOpen:
        return 'Under Review';
      case TransactionStatus.failed:
        return 'Action Required';
      case TransactionStatus.refunded:
        return 'Payment Refunded';
      case TransactionStatus.exception:
        return 'Attention Needed';
    }
  }

  String get customerSubtext {
    switch (this) {
      case TransactionStatus.draft:
      case TransactionStatus.created:
      case TransactionStatus.openForMatching:
        return 'Matching with verified international flights';
      case TransactionStatus.travellerRequested:
        return 'Waiting for traveller to confirm capacity';
      case TransactionStatus.accepted:
        return 'Lock funds securely in escrow to proceed';
      case TransactionStatus.paymentConfirmed:
        return 'Funds safely locked in escrow';
      case TransactionStatus.readyForHandover:
        return 'Verify package seals at origin airport';
      case TransactionStatus.handedToTraveller:
        return 'Package inspected and custody assumed';
      case TransactionStatus.inTransit:
        return 'Flight EK-527 en route to Dubai';
      case TransactionStatus.arrivedAtDestination:
        return 'Landed safely at Dubai International Airport';
      case TransactionStatus.withCourierPartner:
        return 'Transferred to SMYL Logistics Partner for last-mile delivery';
      case TransactionStatus.outForDelivery:
        return 'Package is on the vehicle for delivery to receiver';
      case TransactionStatus.delivered:
      case TransactionStatus.completed:
        return 'Delivery confirmed with OTP; package handed over safely';
      case TransactionStatus.onHold:
        return 'Our operations team is reviewing this shipment';
      case TransactionStatus.cancelled:
        return 'This delivery request has been cancelled';
      default:
        return 'Transaction active';
    }
  }
}
