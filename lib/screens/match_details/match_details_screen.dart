import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match_model.dart';
import '../../providers/app_providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/team_flag.dart';
import 'match_stats_view.dart';
import 'match_rosters_view.dart';
import 'team_matches_tab.dart';

class MatchDetailsScreen extends ConsumerWidget {
  final MatchModel match;

  const MatchDetailsScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(matchDetailsProvider(match.id));

    final homeIsWinner = match.status == MatchStatus.finished && 
        (match.homeTeam?.winner == true || (match.homeTeam?.score != null && match.awayTeam?.score != null && int.tryParse(match.homeTeam!.score!) != null && int.tryParse(match.awayTeam!.score!) != null && int.parse(match.homeTeam!.score!) > int.parse(match.awayTeam!.score!)));
    final awayIsWinner = match.status == MatchStatus.finished && 
        (match.awayTeam?.winner == true || (match.homeTeam?.score != null && match.awayTeam?.score != null && int.tryParse(match.homeTeam!.score!) != null && int.tryParse(match.awayTeam!.score!) != null && int.parse(match.awayTeam!.score!) > int.parse(match.homeTeam!.score!)));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalles del Partido'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Header / Scoreboard
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Column(
                children: [
                  Text(
                    '${AppDateUtils.formatShortDay(match.date)} ${AppDateUtils.formatDayNumber(match.date)} ${AppDateUtils.formatTime(match.date)}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            TeamFlag(logoUrl: match.homeTeam?.logoUrl, teamName: match.homeTeam?.displayName ?? '', size: 64),
                            const SizedBox(height: 8),
                            Text(match.homeTeam?.displayName ?? 'TBD', style: TextStyle(fontWeight: FontWeight.bold, color: homeIsWinner ? AppColors.primary : Colors.white)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (match.status != MatchStatus.upcoming)
                            Row(
                              children: [
                                Text(match.homeTeam?.score ?? '0', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                const Text(' - ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                Text(match.awayTeam?.score ?? '0', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                              ],
                            )
                          else
                            const Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          if (match.status == MatchStatus.live)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.liveGlow, borderRadius: BorderRadius.circular(4)),
                              child: Text(match.displayClock ?? 'En Vivo', style: const TextStyle(color: AppColors.live, fontWeight: FontWeight.bold)),
                            )
                          else if (match.status == MatchStatus.finished)
                            const Text('FINAL', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            TeamFlag(logoUrl: match.awayTeam?.logoUrl, teamName: match.awayTeam?.displayName ?? '', size: 64),
                            const SizedBox(height: 8),
                            Text(match.awayTeam?.displayName ?? 'TBD', style: TextStyle(fontWeight: FontWeight.bold, color: awayIsWinner ? AppColors.primary : Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs
            const TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [
                Tab(text: 'Partidos'),
                Tab(text: 'Estadísticas'),
                Tab(text: 'Alineaciones'),
              ],
            ),
            
            // Content
            Expanded(
              child: summaryAsync.when(
                data: (summary) {
                  return TabBarView(
                    children: [
                      TeamMatchesTab(match: match),
                      MatchStatsView(summary: summary, match: match),
                      MatchRostersView(summary: summary, match: match),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, st) => Center(child: Text('Error cargando detalles: $e', style: const TextStyle(color: AppColors.textSecondary))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
