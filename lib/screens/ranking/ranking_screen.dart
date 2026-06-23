import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/statistic_model.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class RankingScreen extends ConsumerWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);
    final now = DateTime.now();
    final formatted = DateFormat("d MMM yyyy, HH:mm", 'es').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.navRanking,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(statisticsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (List<StatisticCategoryModel> categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'No hay estadísticas disponibles',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return DefaultTabController(
            length: categories.length,
            child: Column(
              children: [
                // "Updated at" banner
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Actualizado el $formatted',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                // Tab bar
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: categories
                        .map((StatisticCategoryModel c) =>
                            Tab(text: c.displayName.toUpperCase()))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: categories
                        .map((StatisticCategoryModel category) =>
                            _buildStatList(category))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                AppStrings.errorLoadFailed,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(statisticsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppStrings.errorRetry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatList(StatisticCategoryModel category) {
    if (category.leaders.isEmpty) {
      return const Center(
        child: Text(
          'Sin datos',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: category.leaders.length,
      itemBuilder: (context, index) {
        final leader = category.leaders[index];
        final isTop3 = index < 3;
        final isFirst = index == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: isFirst
                ? const LinearGradient(
                    colors: [Color(0xFF2A1F00), Color(0xFF1A1200)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isFirst ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFirst
                  ? Colors.amber.withOpacity(0.4)
                  : isTop3
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.border.withOpacity(0.3),
              width: isFirst ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Position number
                SizedBox(
                  width: 28,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isFirst ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: isFirst
                          ? Colors.amber
                          : isTop3
                              ? AppColors.primary
                              : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Player photo
                Container(
                  width: isFirst ? 48 : 40,
                  height: isFirst ? 48 : 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst
                          ? Colors.amber.withOpacity(0.5)
                          : AppColors.border.withOpacity(0.3),
                      width: isFirst ? 2 : 1,
                    ),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: ClipOval(
                    child: leader.athleteHeadshot.isNotEmpty
                        ? Image.network(
                            leader.athleteHeadshot,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: isFirst ? 24 : 20,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                            size: isFirst ? 24 : 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Player info (name + team) — stacked vertically so nothing overlaps
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name row
                      Row(
                        children: [
                          if (isFirst) ...[
                            const Icon(Icons.emoji_events,
                                color: Colors.amber, size: 15),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              leader.athleteName,
                              style: TextStyle(
                                fontWeight:
                                    isFirst ? FontWeight.w800 : FontWeight.w600,
                                fontSize: isFirst ? 15 : 14,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Team row — below the name, never overlapping
                      Row(
                        children: [
                          if (leader.teamLogo.isNotEmpty) ...[
                            Image.network(
                              leader.teamLogo,
                              width: 14,
                              height: 14,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox(width: 14),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              leader.teamName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Stats row — partidos jugados y valor principal (goles, asistencias, etc.)
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          const Icon(Icons.sports_soccer,
                              size: 11, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            '${leader.displayValue}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
