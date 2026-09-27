# SMYL Global

> **Tagline**: *“Your Journey Can Carry More.”*  
> **App Type**: Traveller-Assisted Delivery & Luggage Marketplace Mobile Application  

SMYL Global is a digital platform connecting people who need to send permitted items with verified travellers who have available luggage capacity.

---

## Features

- **Authentication & Onboarding**: Phone and OTP verification flow with dynamic role selection.
- **Sender Workflow**: Create delivery requests with declared weight, item dimensions, and customs declaration.
- **Shipment Matching Engine**: Automated radar matching with scheduled flights, luggage quotas, and verified traveller profiles.
- **Traveller Workflow**: Post upcoming flight journeys, review incoming delivery requests, accept/decline consignments, and monitor baggage allowance.
- **Payment & Escrow Protection**: Transparent fee breakdown (Luggage Reward + Platform Fee + Courier Fee) held securely in escrow until verified delivery.
- **UPI & QR Demo Payment**: Interactive UPI VPA validation (`@okaxis`, `@okhdfcbank`, `@paytm`, `@ybl`) and simulated dynamic QR code with live countdown timer.
- **Two-Sided OTP Handover**: Cryptographic one-time passcodes for origin airport handover (Sender → Traveller) and destination doorstep delivery (Traveller/Courier → Receiver).
- **Real-Time Shipment Tracking**: 10-milestone interactive timeline showing flight departure, in-flight progress, customs clearance, and courier dispatch.
- **Courier Partner Workflow**: Seamless handoff to verified onward logistics partners for deliveries extending beyond the traveller's airport arrival city.
- **Receiver Confirmation Portal**: Zero-login, secure web/mobile portal for receivers to inspect package seals and provide the final delivery OTP.
- **Notifications**: Instant transactional alerts for matching, payment authorization, airport check-in, and delivery completion.
- **Traveller Payout & Wallet**: Instant wallet settlement and escrow release immediately upon OTP verification.
- **Claims & Dispute Resolution**: Item damage and missing parcel claim filing with automatic escrow hold.
- **Admin Operations Dashboard**: Platform-wide telemetry, dispute arbitration, transaction holds, and immutable audit logs.

---

## User Roles

| Role | Responsibility & Key Actions |
| :--- | :--- |
| **Sender** | Creates shipments, searches matching travellers, locks funds in escrow, and validates origin handover with OTP `482913`. |
| **Traveller** | Lists international flight journeys, accepts consignment requests, inspects package seals, carries luggage, and receives escrow payout. |
| **Receiver** | Receives delivery updates, inspects arrival seals, and confirms receipt with secret Delivery OTP `739104`. |
| **Courier Partner** | Takes custody of consignments at destination gateway hub for final last-mile doorstep delivery. |
| **Admin** | Monitors system health, inspects audit logs, manages compliance lists, and arbitrates disputes. |

---

## Main Workflow

```
Sender creates shipment
       ↓
Traveller matching
       ↓
Traveller accepts
       ↓
Payment (Escrow Held)
       ↓
OTP handover (Origin Airport)
       ↓
Traveller carries item (In Flight)
       ↓
Courier handoff if required (Destination Hub)
       ↓
Receiver confirmation (Delivery OTP)
       ↓
Delivery completed
       ↓
Traveller payout (Escrow Released)
```

---

## Project Structure

```
smyl_mobile/
├── android/                   # Native Android host configuration
├── ios/                       # Native iOS host configuration & Xcode workspace
├── web/                       # Flutter Web host runner and PWA manifests
├── lib/
│   ├── main.dart              # Application entry point & GoRouter configuration
│   ├── core/
│   │   ├── constants/         # App constants, routes, asset paths
│   │   ├── demo/              # Centralized demo constants & scenario definitions
│   │   ├── theme/             # Dark premium theme, typography, color palette
│   │   └── widgets/           # Design system components (Buttons, Cards, Badges, etc.)
│   ├── features/
│   │   ├── admin/             # System telemetry & audit dashboards
│   │   ├── auth/              # Login, register, OTP verification, role selection
│   │   ├── claims/            # Dispute filing and claim records
│   │   ├── compliance/        # Prohibited items and customs guidelines
│   │   ├── courier/           # Partner handoff & courier waypoint tracking
│   │   ├── handover/          # Airport origin inspection & OTP verification
│   │   ├── home/              # Main shell, Sender view, Traveller view
│   │   ├── notifications/     # Transactional notification feed
│   │   ├── onboarding/        # First-time user walkthrough
│   │   ├── payment/           # Escrow checkout, UPI validation, digital receipt
│   │   ├── profile/           # User KYC verification, profile details
│   │   ├── receiver/          # Receiver portal & delivery OTP confirmation
│   │   ├── sender/            # Create shipment wizard & matching radar
│   │   ├── splash/            # Animated splash screen
│   │   ├── tracking/          # Live flight tracker & transaction details
│   │   └── traveller/         # Post journey, available requests, earnings
│   └── shared/
│       ├── models/            # Domain models (Transaction, Shipment, Journey, etc.)
│       └── services/          # AppRepository, PaymentService, CourierService, MockData
├── docs/                      # Technical documentation (Workflow, Architecture, Development)
├── test/                      # Unit, state machine, and smoke test suites
├── .env.example               # Environment variables template
├── .gitignore                 # Standard Flutter & security ignore rules
├── pubspec.yaml               # Project dependencies and Flutter assets
└── analysis_options.yaml      # Dart analyzer and linting rules
```

---

## Requirements

Before running the application, ensure your environment has:

- **Flutter SDK**: `^3.13.0` or later (tested on Flutter `3.47.2`)
- **Dart SDK**: `^3.13.0`
- **Google Chrome**: For immediate web preview and testing
- **Android Studio** *(Optional for Android build)*: Android SDK platform tools and emulator
- **Xcode & CocoaPods** *(Optional for iOS/macOS build on Apple silicon/Intel)*: macOS host required

Check your local environment status anytime with:
```bash
flutter doctor
```

---

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd smyl_mobile
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify analyzer & tests**:
   ```bash
   flutter analyze
   flutter test
   ```

---

## Run on Chrome (Recommended for Quick Testing)

You can run the full application directly in Google Chrome without setting up mobile emulators:
```bash
flutter run -d chrome
```

---

## Run on Android

1. List available devices and connected emulators:
   ```bash
   flutter devices
   ```

2. Launch on the selected device:
   ```bash
   flutter run -d <device-id>
   ```

---

## Run on iOS

*Requires macOS with Xcode and CocoaPods installed.*

1. Check for attached iOS simulator or device:
   ```bash
   flutter devices
   ```

2. Run the application:
   ```bash
   flutter run -d <ios-device-id>
   ```

---

## Environment Configuration

A template environment file [`.env.example`](file:///.env.example) is provided at the root of the project:

```bash
cp .env.example .env
```

The application runs out-of-the-box in development mode without needing external API credentials. Real API keys for production services (payment gateways, mapping, SMS OTP) should only be supplied through `.env` and must never be committed to source control.

---

## Demo Mode

To enable friction-free evaluation and demonstrations without logging in and out between different personas, the app includes a persistent **Demo Controller Bar** at the top of the screen:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🟢 MASTER TX: SMYL-2026-000184 • OPEN FOR MATCHING              [ ↺ RESET ] │
├─────────────────────────────────────────────────────────────────────────────┤
│ [ 👤 SENDER ]      [ ✈️ TRAVELLER ]      [ 📦 RECEIVER ]      [ 🛡️ ADMIN ]  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Canonical Demo Transaction

| Parameter | Master Value |
| :--- | :--- |
| **Transaction ID** | `SMYL-2026-000184` |
| **Sender** | **Lakshmi Narayana** (Hyderabad, India) |
| **Traveller** | **Arjun Reddy** (Flight `EK-527`, HYD → DXB, 10 Oct 2026) |
| **Receiver** | **Rahul Kumar** (Downtown Dubai, UAE) |
| **Consignment** | 2.0 KG (*Pashmina Shawls & Sweets*, Declared: ₹8,000) |
| **Pricing Breakdown** | Delivery: ₹1,800 + SMYL Fee: ₹180 + Courier: ₹250 = **Total: ₹2,230** |
| **Escrow Reference** | `SMYL-PAY-2026-008721` |
| **Courier Tracking ID**| `SML-CP-829104` (*SMYL Logistics Partner*) |
| **Origin Handover OTP** | `482913` |
| **Delivery OTP** | `739104` |

### Step-by-Step Testing Flow

1. **Sender (`[ 👤 SENDER ]`)**:
   - View active consignment `SMYL-2026-000184`.
   - Tap `[ Find Matched Travellers (Radar) → ]` and request Arjun Reddy.
2. **Traveller (`[ ✈️ TRAVELLER ]`)**:
   - Tap `[ ✈️ TRAVELLER ]` in the top bar.
   - Accept the incoming consignment request for flight `EK-527`.
3. **Payment (`[ 👤 SENDER ]`)**:
   - Switch back to Sender. Notice the state change to *"Traveller Accepted"*.
   - Tap `[ Pay Escrow (₹2,230) ]` to open the payment screen. Enter any UPI ID (e.g. `lakshmi@okaxis`) or use the QR code.
   - Authorize payment to receive digital receipt `SMYL-PAY-2026-008721`.
4. **Origin Airport Handover**:
   - Switch to `[ ✈️ TRAVELLER ]`.
   - Tap `[ Initiate Airport Handover Protocol → ]` at HYD Gate 4.
   - Validate origin OTP `482913`.
5. **In-Flight & Landing**:
   - Click `[ Depart Hyderabad / Take Off ]` (Status: `IN_TRANSIT`).
   - Click `[ Record Flight Landing in Dubai ]` (Status: `ARRIVED_AT_DESTINATION`).
6. **Courier Partner & Receiver Delivery**:
   - Click `[ Transfer to Courier Partner ]` to assign tracking ID `SML-CP-829104`.
   - Switch to `[ 📦 RECEIVER ]` to view Rahul Kumar's portal with Delivery OTP `739104`.
   - Confirm receipt: status transitions to `DELIVERED`, and ₹1,800 is released to Arjun Reddy's wallet.

---

## Development Notes

- **Backend-Ready Architecture**: The application follows clean architectural boundaries. UI views observe domain state through Riverpod and interact strictly with abstract service contracts (`PaymentService`, `CourierService`, `AppRepository`).
- **Development & Mock Integrations**: Payment collection (UPI regex validation, simulate collect/lock, QR countdown) and courier tracking are currently implemented as **development mock services** (`MockPaymentService`, `MockCourierService`) designed to replicate the exact asynchronous latencies and edge cases of production APIs without incurring test-account charges.
- **Future Production Integrations**: The codebase is pre-structured for seamless drop-in replacements with real payment gateway SDKs (Razorpay/Stripe) and international logistics APIs (DHL/Aramex/FedEx).
