import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import 'team_flag.dart';
import 'live_badge.dart';
import '../screens/match_details/match_details_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchCard extends ConsumerWidget {
  final MatchModel match;
  final bool showDate;
  final bool isClickable;

  const MatchCard({
    Key? key, 
    required this.match,
    this.showDate = false,
    this.isClickable = true,
  }) : super(key: key);

  Widget _buildGoals() {
    if (match.goals.isEmpty) return const SizedBox();
    
    final homeGoals = match.goals.where((g) => g.teamId == match.homeTeam?.id).toList();
    final awayGoals = match.goals.where((g) => g.teamId == match.awayTeam?.id).toList();

    Map<String, List<String>> groupGoals(List<GoalModel> goals) {
      final grouped = <String, List<String>>{};
      for (var g in goals) {
        final minuteStr = "${g.minute}'${g.isPenalty ? " (P)" : ""}";
        if (grouped.containsKey(g.playerName)) {
          grouped[g.playerName]!.add(minuteStr);
        } else {
          grouped[g.playerName] = [minuteStr];
        }
      }
      return grouped;
    }

    final groupedHome = groupGoals(homeGoals);
    final groupedAway = groupGoals(awayGoals);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: groupedHome.entries.map((e) => Text(
                '${e.key} ${e.value.join(", ")}',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.right,
              )).toList(),
            ),
          ),
          const Expanded(flex: 2, child: SizedBox()),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groupedAway.entries.map((e) => Text(
                '${e.key} ${e.value.join(", ")}',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.left,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = match.homeTeam;
    final away = match.awayTeam;
    
    // Build phase label from match data only — do NOT override with groupsProvider
    // because knockout-round teams still appear in group standings.
    final raw = match.groupName ?? '';
    final String displayGroupName = _translatePhase(raw);

    final homeIsWinner = match.status == MatchStatus.finished && 
        (home?.winner == true || (home?.score != null && away?.score != null && int.tryParse(home!.score!) != null && int.tryParse(away!.score!) != null && int.parse(home!.score!) > int.parse(away!.score!)));
    final awayIsWinner = match.status == MatchStatus.finished && 
        (away?.winner == true || (home?.score != null && away?.score != null && int.tryParse(home!.score!) != null && int.tryParse(away!.score!) != null && int.parse(away!.score!) > int.parse(home!.score!)));

    return GestureDetector(
      onTap: isClickable ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match)),
        );
      } : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: match.status == MatchStatus.live ? AppColors.live : AppColors.border,
          width: match.status == MatchStatus.live ? 2.0 : 1.0,
        ),
        boxShadow: match.status == MatchStatus.live
            ? [
                BoxShadow(
                  color: AppColors.live.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayGroupName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (match.status == MatchStatus.live)
                              LiveBadge(
                                matchId: match.id,
                                clock: match.displayClock,
                                clockSeconds: match.clockSeconds,
                                period: match.period,
                                isTicking: match.isTicking,
                                isHalftime: match.isHalftime,
                                compact: true,
                              )
              else if (match.status == MatchStatus.finished)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'FINALIZADO',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      showDate 
                          ? '${AppDateUtils.formatShortDay(match.date)} ${AppDateUtils.formatDayNumber(match.date)} · ${AppDateUtils.formatTime(match.date)}'
                          : AppDateUtils.formatTime(match.date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  showDate 
                      ? '${AppDateUtils.formatShortDay(match.date)} ${AppDateUtils.formatDayNumber(match.date)} · ${AppDateUtils.formatTime(match.date)}'
                      : AppDateUtils.formatTime(match.date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Teams
          Row(
            children: [
              // Home Team
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        home?.displayName ?? 'TBD',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: homeIsWinner ? AppColors.primary : Colors.white, height: 1.1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TeamFlag(logoUrl: home?.logoUrl, teamName: home?.displayName ?? '', size: 24),
                  ],
                ),
              ),
              
              // Score / VS
              Expanded(
                flex: 2,
                child: Center(
                  child: match.status == MatchStatus.upcoming
                      ? const Text('VS', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${home?.score ?? "0"}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: homeIsWinner ? AppColors.primary : Colors.white)),
                            const Text(' - ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            Text('${away?.score ?? "0"}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: awayIsWinner ? AppColors.primary : Colors.white)),
                          ],
                        ),
                ),
              ),
              
              // Away Team
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    TeamFlag(logoUrl: away?.logoUrl, teamName: away?.displayName ?? '', size: 24),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        away?.displayName ?? 'TBD',
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: awayIsWinner ? AppColors.primary : Colors.white, height: 1.1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (match.status == MatchStatus.live || match.status == MatchStatus.finished)
            _buildGoals(),

          const SizedBox(height: 16),
          // Venue
          Text(
            '${match.venue?.fullName ?? "Estadio"} · ${match.venue?.city ?? ""}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    ),
    );
  }
}

String _translatePhase(String raw) {
  if (raw.isEmpty) return 'Fase de Grupos';
  final lower = raw.toLowerCase();
  if (lower.contains('final') && lower.contains('third')) return 'Tercer Lugar';
  if (lower.contains('final') && !lower.contains('semi') && !lower.contains('quarter') && !lower.contains('round')) return 'Final';
  if (lower.contains('semi')) return 'Semifinal';
  if (lower.contains('quarter')) return 'Cuartos de Final';
  if (lower.contains('round of 16') || lower.contains('round of sixteen')) return 'Octavos de Final';
  if (lower.contains('round of 32')) return 'Ronda de 32';
  // Group phase: "Group A", "Grupo B", etc.
  return raw.replaceAll('Group', 'Grupo').replaceAll('group', 'Grupo');
}
