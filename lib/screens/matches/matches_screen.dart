import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../widgets/hero_match_card.dart';
import '../../widgets/match_card.dart';
import '../../widgets/date_selector.dart';
import '../../widgets/loading_skeleton.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../alerts/alerts_screen.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesProvider);
    final heroMatchesAsync = ref.watch(heroMatchesProvider);

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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AlertsScreen()),
                  );
                },
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
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Hero Matches Slider
            ...heroMatchesAsync.when(
              data: (heroMatches) {
                if (heroMatches.isEmpty) return [];

                final isMultiple = heroMatches.length > 1;

                return [
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // PageView of hero cards
                        SizedBox(
                          height: _estimateCardHeight(heroMatches),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: heroMatches.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              return HeroMatchCard(match: heroMatches[index]);
                            },
                          ),
                        ),

                        // Dot indicators — absolutely positioned at top, no spacing impact
                        if (isMultiple)
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                heroMatches.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == _currentPage ? 18 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: i == _currentPage
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ];
              },
              loading: () => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(height: 220, child: const LoadingSkeleton(isSingleItem: true)),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
              error: (e, st) => [],
            ),

            const SliverToBoxAdapter(child: DateSelector()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Matches List
            ...matchesAsync.when(
              data: (matches) {
                if (matches.isEmpty) {
                  return [
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(AppStrings.errorNoMatches, style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  ];
                }

                return [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MatchCard(match: matches[index]),
                      childCount: matches.length,
                    ),
                  ),
                ];
              },
              loading: () => [const SliverToBoxAdapter(child: LoadingSkeleton())],
              error: (e, st) => [
                const SliverToBoxAdapter(
                  child: Center(child: Text(AppStrings.errorLoadFailed)),
                ),
              ],
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  /// Approximate card height so the Stack doesn't collapse.
  /// Live matches with commentary are taller.
  double _estimateCardHeight(List matches) {
    // Enough for the tallest card (live with 2 commentary items)
    return 420;
  }
}
