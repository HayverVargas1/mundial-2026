import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_providers.dart';
import '../../widgets/group_table.dart';
import '../../widgets/loading_skeleton.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.groups, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(groupsProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  const Color.fromARGB(255, 79, 223, 66).withOpacity(0.20),
                  'Avanzan a siguiente ronda',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  const Color.fromARGB(255, 218, 221, 60).withOpacity(0.20),
                  'Mejores terceros',
                ),
              ],
            ),
          ),
        ),
      ),
      body: groupsAsync.when(
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('No hay grupos disponibles'));
          }

          final thirdPlaces = groups.where((g) => g.standings.length >= 3).map((g) => g.standings[2]).toList();
          thirdPlaces.sort((a, b) {
            if (a.points != b.points) return b.points.compareTo(a.points);
            if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
            return b.goalsFor.compareTo(a.goalsFor);
          });
          final topThirdPlacesIds = thirdPlaces.take(8).map((e) => e.team.id).toSet();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(groupsProvider);
            },
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return GroupTable(
                  group: groups[index],
                  topThirdPlacesIds: topThirdPlacesIds,
                  showHeader: true,
                );
              },
            ),
          );
        },
        loading: () => const LoadingSkeleton(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.errorLoadFailed),
              ElevatedButton(
                onPressed: () => ref.invalidate(groupsProvider),
                child: Text(AppStrings.errorRetry),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
