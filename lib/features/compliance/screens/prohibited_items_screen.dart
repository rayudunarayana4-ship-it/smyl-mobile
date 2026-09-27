import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/smyl_card.dart';
import '../../../shared/models/prohibited_rule_model.dart';
import '../../../shared/services/app_repository.dart';

class ProhibitedItemsScreen extends ConsumerStatefulWidget {
  const ProhibitedItemsScreen({super.key});

  @override
  ConsumerState<ProhibitedItemsScreen> createState() =>
      _ProhibitedItemsScreenState();
}

class _ProhibitedItemsScreenState extends ConsumerState<ProhibitedItemsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(appRepositoryProvider);
    final rules = repo.prohibitedRules;

    final filtered = rules.where((r) {
      return r.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.rationale.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          'COMPLIANCE & PROHIBITED ITEMS',
          style: AppTypography.labelUppercase.copyWith(
            color: AppColors.warmIvory,
            fontSize: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Warning Alert Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel_rounded,
                      color: AppColors.danger, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANDATORY INTERNATIONAL AVIATION COMPLIANCE',
                          style: AppTypography.labelUppercase.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Attempting to transport prohibited goods or hazardous materials without documentation is a punishable federal offence under ICAO/IATA conventions.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warmIvory,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: AppTypography.bodyMedium.copyWith(color: AppColors.warmIvory),
              decoration: InputDecoration(
                hintText: 'Search rules (e.g. lithium, seeds, perfume)...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.slate, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'RESTRICTED & PROHIBITED CATEGORIES',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.slateLight,
              ),
            ),
            const SizedBox(height: 10),

            ...filtered.map((rule) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: SmylCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getRestrictionColor(rule.restrictionLevel)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getRestrictionColor(rule.restrictionLevel)
                                    .withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              rule.restrictionLevel.label,
                              style: AppTypography.labelUppercase.copyWith(
                                color:
                                    _getRestrictionColor(rule.restrictionLevel),
                                fontSize: 9,
                              ),
                            ),
                          ),
                          Text(
                            rule.category.toUpperCase(),
                            style: AppTypography.labelUppercase.copyWith(
                              color: AppColors.champagneSand,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text(
                        rule.itemName,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        rule.rationale,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.slateLight,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.deepSpace,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                size: 14, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rule.penaltyNotice,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.champagneSand,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Permitted Categories Overview
            Text(
              'PERMITTED & ENCOURAGED CATEGORIES',
              style: AppTypography.labelUppercase.copyWith(
                color: AppColors.auroraTeal,
              ),
            ),
            const SizedBox(height: 10),

            SmylCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: AppConstants.permittedCategories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 16, color: AppColors.auroraTeal),
                        const SizedBox(width: 12),
                        Text(
                          cat,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.warmIvory,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getRestrictionColor(RestrictionLevel level) {
    switch (level) {
      case RestrictionLevel.strictlyProhibited:
        return AppColors.danger;
      case RestrictionLevel.permitRequired:
        return AppColors.warning;
      case RestrictionLevel.declarationRequired:
        return AppColors.electricCyan;
    }
  }
}
