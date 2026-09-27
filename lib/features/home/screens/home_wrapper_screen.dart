import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/demo_role_switcher.dart';
import '../../../core/widgets/smyl_logo.dart';
import '../../../core/widgets/smyl_status_badge.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/app_repository.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../receiver/screens/receiver_portal_screen.dart';
import '../../tracking/screens/live_tracking_screen.dart';
import '../../traveller/screens/available_requests_screen.dart';
import '../../traveller/screens/earnings_screen.dart';
import 'sender_home_view.dart';
import 'traveller_home_view.dart';

class HomeWrapperScreen extends ConsumerStatefulWidget {
  const HomeWrapperScreen({super.key});

  @override
  ConsumerState<HomeWrapperScreen> createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends ConsumerState<HomeWrapperScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final user = repo.currentUser;

    // Special Role Handling: Direct full-screen views for Receiver and Admin
    if (user.role == UserRole.receiver) {
      return Scaffold(
        backgroundColor: AppColors.obsidian,
        body: SafeArea(
          child: Column(
            children: const [
              DemoRoleSwitcher(),
              Expanded(child: ReceiverPortalScreen()),
            ],
          ),
        ),
      );
    }

    if (user.role == UserRole.admin) {
      return Scaffold(
        backgroundColor: AppColors.obsidian,
        body: SafeArea(
          child: Column(
            children: const [
              DemoRoleSwitcher(),
              Expanded(child: AdminDashboardScreen()),
            ],
          ),
        ),
      );
    }

    final isTraveller = user.role == UserRole.traveller;

    final List<Widget> pages = isTraveller
        ? [
            const TravellerHomeView(),
            const _JourneysListView(),
            const AvailableRequestsScreen(),
            const EarningsScreen(),
            const ProfileScreen(),
          ]
        : [
            const SenderHomeView(),
            const _ShipmentsListView(),
            const LiveTrackingScreen(),
            const NotificationsScreen(),
            const ProfileScreen(),
          ];

    final List<BottomNavigationBarItem> navItems = isTraveller
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.connecting_airports_outlined),
              activeIcon: Icon(Icons.connecting_airports_rounded),
              label: 'JOURNEYS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inbox_outlined),
              activeIcon: Icon(Icons.inbox_rounded),
              label: 'REQUESTS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'EARNINGS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'PROFILE',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'SHIPMENTS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.radar_outlined),
              activeIcon: Icon(Icons.radar_rounded),
              label: 'TRACK',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: repo.unreadNotificationsCount > 0,
                label: Text(repo.unreadNotificationsCount.toString()),
                backgroundColor: AppColors.electricCyan,
                textColor: AppColors.obsidian,
                child: const Icon(Icons.notifications_none_rounded),
              ),
              activeIcon: const Icon(Icons.notifications_rounded),
              label: 'ALERTS',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'PROFILE',
            ),
          ];

    final currentIndex = _selectedIndex.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: AppColors.obsidian,
        elevation: 0,
        title: const SmylLogo(size: 28, showText: true),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: repo.unreadNotificationsCount > 0,
              label: Text(repo.unreadNotificationsCount.toString()),
              backgroundColor: AppColors.electricCyan,
              textColor: AppColors.obsidian,
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.warmIvory, size: 22),
            ),
            onPressed: () {
              setState(() => _selectedIndex = 3); // Go to Alerts
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.deepSpace,
              child: Text(
                user.name.split(' ').first[0],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.electricCyan,
                ),
              ),
            ),
            onPressed: () {
              setState(() => _selectedIndex = 4); // Go to Profile
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const DemoRoleSwitcher(),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.bottomNav,
          selectedItemColor: AppColors.electricCyan,
          unselectedItemColor: AppColors.slate,
          currentIndex: currentIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: navItems,
        ),
      ),
    );
  }
}

class _ShipmentsListView extends ConsumerWidget {
  const _ShipmentsListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final shipments = repo.shipments;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY SHIPMENTS',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.electricCyan),
              onPressed: () => context.push(AppRoutes.createShipment),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...shipments.map((shp) {
          final tx = repo.transactions.firstWhere(
            (t) => t.shipmentId == shp.id,
            orElse: () => repo.transactions.first,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              tileColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              title: Text(
                '${shp.pickupCity} → ${shp.destCity}',
                style: AppTypography.titleMedium.copyWith(fontSize: 14),
              ),
              subtitle: Text(
                '${shp.weightKg} KG • ${shp.itemDescription}',
                style: AppTypography.bodySmall,
              ),
              trailing: SmylStatusBadge(status: shp.status),
              onTap: () {
                context.push(
                  '${AppRoutes.tracking}/${tx.id}',
                  extra: tx,
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _JourneysListView extends ConsumerWidget {
  const _JourneysListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(appRepositoryProvider);
    final journeys = repo.journeys;

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY TRAVEL JOURNEYS',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.auroraTeal),
              onPressed: () => context.push(AppRoutes.postJourney),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...journeys.map((jrn) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              tileColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              title: Text(
                '${jrn.originCity} → ${jrn.destCity}',
                style: AppTypography.titleMedium.copyWith(fontSize: 14),
              ),
              subtitle: Text(
                'Available: ${jrn.availableCapacityKg} KG • ${jrn.flightNumber}',
                style: AppTypography.bodySmall,
              ),
              trailing: Text(
                '₹${jrn.estimatedEarnings.toStringAsFixed(0)}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.champagneSand,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
