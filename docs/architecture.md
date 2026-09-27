# SMYL Global — Technical Architecture

> **Framework**: Flutter 3.47 / Dart 3.13  
> **State Management**: Flutter Riverpod 3.4.3  
> **Navigation**: GoRouter 18.0.1  

---

## 1. High-Level Architectural Layers

The application is structured into decoupled layers following clean architectural principles:

```
┌────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                   │
│  - Feature Screens (Sender, Traveller, Receiver, etc.) │
│  - Core Reusable UI Widgets (SmylButton, SmylCard)     │
│  - Dark Theme Tokens (AppColors, AppTypography)        │
└───────────────────────────▲────────────────────────────┘
                            │ ref.watch / ref.read
┌───────────────────────────┴────────────────────────────┐
│                 STATE MANAGEMENT LAYER                 │
│  - Riverpod StateNotifier / ChangeNotifier Providers   │
│  - Single Source of Truth AppRepository                │
└───────────────────────────▲────────────────────────────┘
                            │ Orchestrates
┌───────────────────────────┴────────────────────────────┐
│                 DOMAIN & SERVICE LAYER                 │
│  - PaymentService / MockPaymentService                 │
│  - CourierService / MockCourierService                 │
│  - State Machine Validation (TransactionStatus)        │
└───────────────────────────▲────────────────────────────┘
                            │ Consumes
┌───────────────────────────┴────────────────────────────┐
│                    DATA MODEL LAYER                    │
│  - TransactionModel, ShipmentModel, JourneyModel       │
│  - UserModel, TrackingEventModel, AuditLogModel        │
│  - Centralized Canonical Demo Data (DemoData)          │
└────────────────────────────────────────────────────────┘
```

---

## 2. Directory Layout & Organization

```
lib/
├── core/
│   ├── constants/             # Global strings, asset references, route names
│   ├── demo/                  # Canonical demo data constants (DemoData)
│   ├── theme/                 # AppColors, AppTypography, AppTheme
│   └── widgets/               # Standardized design system components
├── features/                  # Feature slices encapsulating screens and controllers
│   ├── admin/                 # Audit logs, telemetry, operational controls
│   ├── auth/                  # Login, OTP verification, role selection
│   ├── claims/                # Dispute handling & insurance claim screens
│   ├── compliance/            # Customs declarations & prohibited items
│   ├── courier/               # Courier waypoint tracking & handoff
│   ├── handover/              # Origin airport inspection & OTP entry
│   ├── home/                  # Role-aware dashboard shell & home views
│   ├── notifications/         # Notification feed
│   ├── onboarding/            # First-time user onboarding screens
│   ├── payment/               # Escrow checkout, QR modal, digital receipt
│   ├── profile/               # KYC documents & account settings
│   ├── receiver/              # Receiver delivery portal & OTP confirmation
│   ├── sender/                # Shipment creation & traveller matching radar
│   ├── splash/                # Brand splash screen
│   ├── tracking/              # Real-time transaction & flight tracking
│   └── traveller/             # Post journey, available requests, wallet
└── shared/
    ├── models/                # Immutable domain entities and state enums
    └── services/              # AppRepository, PaymentService, CourierService
```

---

## 3. State Management with Riverpod

State management centers around [`appRepositoryProvider`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/shared/services/app_repository.dart):

```dart
final appRepositoryProvider = ChangeNotifierProvider<AppRepository>((ref) {
  return AppRepository();
});
```

### Key Responsibilities of `AppRepository`:
1. **Persona Switching**: Maintains `currentUser` and supports instant toggling via `switchDemoRole(UserRole role)`.
2. **Master Transaction Orchestration**: Exposes `primaryTransaction`, `primaryShipment`, and `primaryJourney` to eliminate hardcoded duplicate state.
3. **Finite State Transitions**: Enforces valid status transitions using `status.canTransitionTo(nextStatus)`:
   - Prevents skipping origin OTP before taking off.
   - Prevents releasing escrow payouts before delivery OTP confirmation.
4. **Service Delegation**: Coordinates payment collect/refund logic through `PaymentService` and waypoint tracking via `CourierService`.

---

## 4. Navigation Architecture (`GoRouter`)

Declarative routing is handled via `GoRouter` in [`lib/main.dart`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/main.dart) using route constants defined in [`AppRoutes`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/core/constants/route_constants.dart).

Key patterns:
- **Dynamic Path Parameters**: `/tracking/:id`, `/courier-tracking/:id`, `/otp-handover/:id`, `/receiver-portal/:id`.
- **Payload Passing via `state.extra`**: Allows passing domain models directly between routes while gracefully falling back to `repo.primaryTransaction` if navigated to directly or refreshed in browser environments.

---

## 5. Design System & Theming

The application enforces a **Dark Luxury & Cyber Logistics Aesthetic**:
- **Backgrounds**: `AppColors.obsidian` (`#070A10`), `AppColors.deepSpace` (`#0D121F`), `AppColors.surfaceCard` (`#141C2E`).
- **Brand Accents**: `AppColors.electricCyan` (`#00F2FE`), `AppColors.auroraTeal` (`#00C9A7`), `AppColors.champagneSand` (`#E6D5B8`).
- **Semantic Status**: `AppColors.emeraldVerified` (`#00E676`), `AppColors.sunsetAmber` (`#FF9100`), `AppColors.danger` (`#FF5252`).
- **Typography**: Google Fonts Inter hierarchy paired with Space Grotesk accents for airport codes and flight badges.
