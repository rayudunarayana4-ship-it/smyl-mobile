// ==============================================================================
// SMYL GLOBAL — CANONICAL DEMO DATA REPOSITORY
// ==============================================================================
// This file defines the single source of truth for all demo and development
// workflows across the SMYL Global application.
//
// In DEMO MODE, every module (Sender, Traveller, Receiver, Payment, Courier,
// Tracking, Admin) connects to this single master operational transaction.
// ==============================================================================

class DemoData {
  DemoData._();

  // ---------------------------------------------------------------------------
  // Canonical Master Transaction Identification
  // ---------------------------------------------------------------------------
  static const String shipmentId = 'SMYL-2026-000184';
  static const String journeyId = 'SMYL-JRN-2026';
  static const String paymentReference = 'SMYL-PAY-2026-008721';
  static const String courierTrackingId = 'SML-CP-829104';

  // ---------------------------------------------------------------------------
  // Secure Two-Sided Verification OTPs
  // ---------------------------------------------------------------------------
  /// Origin OTP: Held by Sender (Lakshmi); entered by Traveller at HYD Departure.
  static const String originHandoverOtp = '482913';

  /// Delivery OTP: Held by Receiver (Rahul); entered by Courier on final delivery.
  static const String deliveryHandoverOtp = '739104';

  // ---------------------------------------------------------------------------
  // Persona: Sender
  // ---------------------------------------------------------------------------
  static const String senderId = 'usr_lakshmi_01';
  static const String senderName = 'Lakshmi Narayana';
  static const String senderPhone = '+91 98490 12345';
  static const String senderCity = 'Hyderabad';
  static const String senderCountry = 'India';
  static const String senderAddress = 'Banjara Hills, Road No. 12';
  static const String originAirportCode = 'HYD';

  // ---------------------------------------------------------------------------
  // Persona: Verified Traveller
  // ---------------------------------------------------------------------------
  static const String travellerId = 'trv_arjun_01';
  static const String travellerName = 'Arjun Reddy';
  static const double travellerRating = 4.8;
  static const int travellerDeliveries = 24;
  static const String airline = 'Emirates';
  static const String flightNumber = 'EK-527';
  static const String departureTime = '10:30 AM';
  static const String arrivalTime = '01:15 PM';
  static const String handoverPreference = 'Airport Departure Gate 4';

  // ---------------------------------------------------------------------------
  // Persona: Receiver
  // ---------------------------------------------------------------------------
  static const String receiverId = 'rcv_rahul_01';
  static const String receiverName = 'Rahul Kumar';
  static const String receiverPhone = '+971 50 123 4567';
  static const String destCity = 'Dubai';
  static const String destCountry = 'United Arab Emirates';
  static const String destAddress = 'Downtown Dubai Residence';
  static const String destAirportCode = 'DXB';

  // ---------------------------------------------------------------------------
  // Consignment Specifications
  // ---------------------------------------------------------------------------
  static const String itemCategory = 'Personal permitted item';
  static const String itemDescription =
      'Hand-woven Pashmina & Traditional Indian Confectionery';
  static const double weightKg = 2.0;
  static const double declaredValue = 8000.0;
  static const String currency = 'INR';

  // ---------------------------------------------------------------------------
  // Financial & Escrow Breakdown (Total: ₹2,230.00)
  // ---------------------------------------------------------------------------
  /// Traveller luggage reward payout: ₹1,800.00
  static const double travellerPayout = 1800.0;

  /// SMYL platform facilitation & escrow protection fee: ₹180.00
  static const double platformFee = 180.0;

  /// Last-mile courier transit fee: ₹250.00
  static const double courierFee = 250.0;

  /// Total escrow amount locked: ₹2,230.00
  static const double totalAmount = 2230.0;

  // ---------------------------------------------------------------------------
  // Onward Courier Logistics Partner
  // ---------------------------------------------------------------------------
  static const String courierPartnerName = 'SMYL Logistics Partner';
  static const String courierPartnerId = 'cr_smyl_logistics';
  static const String courierRiderName = 'Mohammed S. (Verified Partner Rider)';
  static const String courierRiderPhone = '+971 52 881 2940';
  static const String courierGatewayHub =
      'Dubai International Gateway Hub (DXB Terminal 3 Freight Station)';
}
