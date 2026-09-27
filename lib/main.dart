import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/mobile_device_frame.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_verification_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/claims/screens/claims_list_screen.dart';
import 'features/claims/screens/file_claim_screen.dart';
import 'features/compliance/screens/prohibited_items_screen.dart';
import 'features/courier/screens/courier_handoff_screen.dart';
import 'features/courier/screens/courier_tracking_screen.dart';
import 'features/handover/screens/otp_handover_screen.dart';
import 'features/home/screens/home_wrapper_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/payment/screens/payment_screen.dart';
import 'features/payment/screens/payment_receipt_screen.dart';
import 'features/profile/screens/kyc_verification_screen.dart';
import 'features/receiver/screens/receiver_portal_screen.dart';
import 'features/sender/screens/create_shipment_wizard_screen.dart';
import 'features/sender/screens/find_traveller_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/tracking/screens/live_tracking_screen.dart';
import 'features/tracking/screens/transaction_detail_screen.dart';
import 'features/traveller/screens/earnings_screen.dart';
import 'features/traveller/screens/post_journey_screen.dart';
import 'shared/models/shipment_model.dart';
import 'shared/models/transaction_model.dart';
import 'shared/services/payment_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: SmylGlobalApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.roleSelect,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.otpVerify,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OtpVerificationScreen(
          phoneOrEmail: extra?['phoneOrEmail'] as String? ?? '+91 98490 12345',
          isLogin: extra?['isLogin'] as bool? ?? true,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.mainShell,
      builder: (context, state) => const HomeWrapperScreen(),
    ),
    GoRoute(
      path: AppRoutes.createShipment,
      builder: (context, state) => const CreateShipmentWizardScreen(),
    ),
    GoRoute(
      path: AppRoutes.findTraveller,
      builder: (context, state) {
        final shipment = state.extra as ShipmentModel?;
        return FindTravellerScreen(shipment: shipment);
      },
    ),
    GoRoute(
      path: AppRoutes.payment,
      builder: (context, state) {
        final tx = state.extra as TransactionModel?;
        return PaymentScreen(transaction: tx);
      },
    ),
    GoRoute(
      path: AppRoutes.paymentReceipt,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentReceiptScreen(
          receipt: extra?['receipt'] as PaymentReceipt?,
          transaction: extra?['transaction'] as TransactionModel?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.transactionDetail,
      builder: (context, state) {
        final tx = state.extra as TransactionModel?;
        return TransactionDetailScreen(transaction: tx);
      },
    ),
    GoRoute(
      path: '${AppRoutes.transactionDetail}/:id',
      builder: (context, state) {
        final tx = state.extra as TransactionModel?;
        return TransactionDetailScreen(transaction: tx);
      },
    ),
    GoRoute(
      path: AppRoutes.courierTracking,
      builder: (context, state) {
        final tx = state.extra as TransactionModel?;
        return CourierTrackingScreen(transaction: tx);
      },
    ),
    GoRoute(
      path: '${AppRoutes.courierTracking}/:id',
      builder: (context, state) {
        final trackingId = state.pathParameters['id'];
        final tx = state.extra as TransactionModel?;
        return CourierTrackingScreen(
          trackingId: trackingId,
          transaction: tx,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.postJourney,
      builder: (context, state) => const PostJourneyScreen(),
    ),
    GoRoute(
      path: AppRoutes.earnings,
      builder: (context, state) => const EarningsScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.tracking}/:id',
      builder: (context, state) {
        final txId = state.pathParameters['id'];
        final tx = state.extra as TransactionModel?;
        return LiveTrackingScreen(
          transactionId: txId,
          transaction: tx,
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.otpHandover}/:id',
      builder: (context, state) {
        final txId = state.pathParameters['id'];
        final tx = state.extra as TransactionModel?;
        return OtpHandoverScreen(
          transactionId: txId,
          transaction: tx,
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.courierHandoff}/:id',
      builder: (context, state) {
        final txId = state.pathParameters['id'];
        final tx = state.extra as TransactionModel?;
        return CourierHandoffScreen(
          transactionId: txId,
          transaction: tx,
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.receiverPortal}/:id',
      builder: (context, state) {
        final txId = state.pathParameters['id'];
        final tx = state.extra as TransactionModel?;
        return ReceiverPortalScreen(
          transactionId: txId,
          transaction: tx,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.claims,
      builder: (context, state) => const ClaimsListScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.fileClaim}/:id',
      builder: (context, state) {
        final txId = state.pathParameters['id'];
        final tx = state.extra as TransactionModel?;
        return FileClaimScreen(
          initialTransactionId: txId,
          initialTransaction: tx,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.fileClaim,
      builder: (context, state) => const FileClaimScreen(),
    ),
    GoRoute(
      path: AppRoutes.kycVerification,
      builder: (context, state) => const KycVerificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.prohibitedItems,
      builder: (context, state) => const ProhibitedItemsScreen(),
    ),
    GoRoute(
      path: AppRoutes.admin,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);

class SmylGlobalApp extends StatelessWidget {
  const SmylGlobalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      builder: (context, child) {
        return MobileDeviceFrame(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
