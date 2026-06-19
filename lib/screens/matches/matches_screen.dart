import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_providers.dart';
import '../../widgets/hero_match_card.dart';
import '../../widgets/match_card.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/loading_skeleton.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../models/match_model.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesProvider);
    final heroMatchAsync = ref.watch(heroMatchProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tournamentName,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => ref.invalidate(matchesProvider),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Text(
                    'H.V',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(matchesProvider);
        },
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: const SizedBox(height: 16),
            ),
            
            // Hero Match
            ...heroMatchAsync.when(
              data: (heroMatch) {
                if (heroMatch == null) return [];
                return [
                  SliverToBoxAdapter(
                    child: HeroMatchCard(match: heroMatch),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ];
              },
              loading: () => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 200,
                      child: const LoadingSkeleton(isSingleItem: true),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
              error: (e, st) => [],
            ),
            
            const SliverToBoxAdapter(
              child: DateSelector(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Matches List
            ...matchesAsync.when(
              data: (matches) {
                if (matches.isEmpty) {
                  return [
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          AppStrings.errorNoMatches,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ];
                }

                return [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return MatchCard(match: matches[index]);
                      },
                      childCount: matches.length,
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverToBoxAdapter(child: LoadingSkeleton()),
              ],
              error: (e, st) => [
                const SliverToBoxAdapter(
                  child: Center(child: Text(AppStrings.errorLoadFailed)),
                ),
              ],
            ),
            
            SliverToBoxAdapter(
              child: const SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}
