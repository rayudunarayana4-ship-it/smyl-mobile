import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../core/widgets/smyl_empty_state.dart';
import '../../../shared/models/notification_item.dart';
import '../../../shared/services/app_repository.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final allNotifications = repo.notifications;

    final filtered = _selectedCategory == null
        ? allNotifications
        : allNotifications
            .where((n) => n.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'NOTIFICATION DISPATCH',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => repo.markAllNotificationsAsRead(),
            child: Text(
              'READ ALL',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.electricCyan,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildCategoryChip('ALL', null),
                  const SizedBox(width: 8),
                  ...NotificationCategory.values.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildCategoryChip(cat.label, cat),
                    );
                  }),
                ],
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                  ? const SmylEmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'No Notifications',
                      message:
                          'All clear! You have no alerts in this category.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final notif = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: SmylCard(
                            isHighlighted: !notif.isRead,
                            padding: const EdgeInsets.all(16),
                            onTap: () {
                              repo.markNotificationAsRead(notif.id);
                              if (notif.relatedTransactionId != null) {
                                context.push(
                                  '${AppRoutes.tracking}/${notif.relatedTransactionId}',
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(notif.category)
                                        .withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(notif.category),
                                    color: _getCategoryColor(notif.category),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            notif.category.label,
                                            style: AppTypography.labelUppercase
                                                .copyWith(
                                              fontSize: 9,
                                              color: _getCategoryColor(
                                                  notif.category),
                                            ),
                                          ),
                                          Text(
                                            DateFormat('d MMM, HH:mm')
                                                .format(notif.timestamp),
                                            style: AppTypography.bodySmall
                                                .copyWith(
                                              fontSize: 10,
                                              color: AppColors.slate,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.title,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                          fontSize: 14,
                                          fontWeight: notif.isRead
                                              ? FontWeight.w600
                                              : FontWeight.w800,
                                          color: AppColors.warmIvory,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.body,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.slateLight,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!notif.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.electricCyan,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, NotificationCategory? cat) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricCyan : AppColors.deepSpace,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.electricCyan : AppColors.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.obsidian : AppColors.slateLight,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.transaction:
        return AppColors.electricCyan;
      case NotificationCategory.verification:
        return AppColors.auroraTeal;
      case NotificationCategory.security:
        return AppColors.warning;
      case NotificationCategory.payout:
        return AppColors.champagneSand;
      case NotificationCategory.system:
        return AppColors.info;
    }
  }

  IconData _getCategoryIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.transaction:
        return Icons.local_shipping_rounded;
      case NotificationCategory.verification:
        return Icons.verified_user_rounded;
      case NotificationCategory.security:
        return Icons.shield_rounded;
      case NotificationCategory.payout:
        return Icons.account_balance_wallet_rounded;
      case NotificationCategory.system:
        return Icons.tune_rounded;
    }
  }
}
