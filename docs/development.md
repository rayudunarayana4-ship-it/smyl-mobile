# SMYL Global — Developer Guide

This guide is designed for developers joining the SMYL Global project. It covers setup, local execution, testing, demo mode, and how to add new features.

---

## 1. Prerequisites & Environment Setup

### Required Tools
- **Flutter SDK**: `^3.13.0` or higher (verified on `3.47.2`)
- **Dart SDK**: `^3.13.0`
- **Google Chrome**: Recommended for fast, immediate UI development without emulator overhead
- **Git**

Verify your setup:
```bash
flutter doctor
```

---

## 2. Installation & First Run

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd smyl_mobile
   ```

2. Fetch Flutter packages:
   ```bash
   flutter pub get
   ```

3. Run static analyzer and unit tests:
   ```bash
   flutter analyze
   flutter test
   ```

4. Launch the application in Chrome:
   ```bash
   flutter run -d chrome
   ```

---

## 3. Native Platform Setup (Optional)

### Android
1. Install **Android Studio** and the Android SDK command-line tools.
2. Configure an Android Virtual Device (AVD) with API Level 33+.
3. Run:
   ```bash
   flutter devices
   flutter run -d <android-device-id>
   ```

### iOS / macOS
1. Requires a macOS host with **Xcode** installed.
2. Install CocoaPods:
   ```bash
   sudo gem install cocoapods
   ```
3. Run on the iOS Simulator:
   ```bash
   flutter run -d <ios-simulator-id>
   ```

---

## 4. Understanding & Using DEMO MODE

To simplify cross-role testing, the app includes a persistent top **`DemoRoleSwitcher`** component:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🟢 MASTER TX: SMYL-2026-000184 • OPEN FOR MATCHING              [ ↺ RESET ] │
├─────────────────────────────────────────────────────────────────────────────┤
│ [ 👤 SENDER ]      [ ✈️ TRAVELLER ]      [ 📦 RECEIVER ]      [ 🛡️ ADMIN ]  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### The 4 Active Personas
- **`[ 👤 SENDER ]`**: Lakshmi Narayana (`usr_lakshmi_01`). Drives shipment creation, traveller radar search, escrow payments, and origin handover OTP generation.
- **`[ ✈️ TRAVELLER ]`**: Arjun Reddy (`trv_arjun_01`). Drives flight journey posting, request acceptance, airport origin inspection, take-off, and landing.
- **`[ 📦 RECEIVER ]`**: Rahul Kumar (`rcv_rahul_01`). Displays the receiver portal, parcel inspection checklist, and delivery OTP (`739104`).
- **`[ 🛡️ ADMIN ]`**: Platform Administrator. Displays dispute resolution controls, transaction holds, and immutable audit logs.
- **`[ ↺ RESET ]`**: Restores the entire system state back to initial matching status (`OPEN_FOR_MATCHING`) with a single click.

All demo constants are centralized in [`lib/core/demo/demo_data.dart`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/core/demo/demo_data.dart).

---

## 5. Adding a New Feature or Screen

To add a new feature cleanly, follow these 4 steps:

### Step 1: Create the Feature Screen
Create your screen inside `lib/features/<feature_name>/screens/`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_button.dart';
import '../../../shared/services/app_repository.dart';

class SampleFeatureScreen extends ConsumerWidget {
  const SampleFeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final tx = repo.primaryTransaction;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text('Sample Feature', style: AppTypography.titleLarge),
        backgroundColor: AppColors.deepSpace,
      ),
      body: Center(
        child: Text(
          'Active Shipment: ${tx.shipmentId}',
          style: AppTypography.bodyMedium,
        ),
      ),
    );
  }
}
```

### Step 2: Register the Route
Add the route string in [`lib/core/constants/route_constants.dart`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/core/constants/route_constants.dart):
```dart
static const String sampleFeature = '/sample-feature';
```

Register the `GoRoute` in [`lib/main.dart`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/main.dart):
```dart
GoRoute(
  path: AppRoutes.sampleFeature,
  builder: (context, state) => const SampleFeatureScreen(),
),
```

### Step 3: Add Repository / State Handlers
If your feature modifies transaction or user state, add dedicated methods to [`AppRepository`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/shared/services/app_repository.dart):
```dart
void performSampleAction(String txId) {
  // Update transaction and notify listeners
  notifyListeners();
}
```

### Step 4: Write Automated Tests
Add test coverage in [`test/smyl_unit_test.dart`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/test/smyl_unit_test.dart):
```dart
test('Sample feature performs action correctly', () {
  final repo = AppRepository();
  repo.performSampleAction('SMYL-2026-000184');
  expect(repo.primaryTransaction.id, 'SMYL-2026-000184');
});
```

---

## 6. Code Style & Quality Standards

- Run `flutter analyze` before committing. Ensure **0 errors and 0 warnings**.
- Never hardcode color hex codes directly in screen widgets; use [`AppColors`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/core/theme/app_colors.dart).
- Never hardcode font styles; use [`AppTypography`](file:///Users/umamaheshwar/Desktop/vayra-footwear/smyl_mobile/lib/core/theme/app_typography.dart).
- Never commit credentials or `.env` files with secret values.
