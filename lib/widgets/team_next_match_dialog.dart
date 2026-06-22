import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_model.dart';
import '../models/match_model.dart';
import '../providers/app_providers.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/date_utils.dart';
import 'match_card.dart';

class TeamNextMatchDialog extends ConsumerWidget {
  final TeamModel team;

  const TeamNextMatchDialog({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMatchesAsync = ref.watch(allMatchesProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Próximo partido de ${team.displayName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            allMatchesAsync.when(
              data: (matches) {
                // Find next match
                final teamMatches = matches.where((m) => 
                  (m.homeTeam?.id == team.id || m.awayTeam?.id == team.id) &&
                  m.status != MatchStatus.finished
                ).toList();
                
                if (teamMatches.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No hay partidos programados.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                teamMatches.sort((a, b) => a.date.compareTo(b.date));
                final nextMatch = teamMatches.first;

                return MatchCard(match: nextMatch);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(AppStrings.errorLoadFailed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
