import 'dart:async';
import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import 'team_flag.dart';
import 'countdown_widget.dart';
import 'live_badge.dart';
import '../screens/match_details/match_details_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class HeroMatchCard extends ConsumerStatefulWidget {
  final MatchModel match;

  const HeroMatchCard({Key? key, required this.match}) : super(key: key);

  @override
  ConsumerState<HeroMatchCard> createState() => _HeroMatchCardState();
}

class _HeroMatchCardState extends ConsumerState<HeroMatchCard> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.match.status == MatchStatus.live) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        ref.invalidate(matchDetailsProvider(widget.match.id));
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Widget _buildGoals() {
    final match = widget.match;
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
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: groupedHome.entries.map((e) => Text(
                '${e.key} ${e.value.join(", ")}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              )).toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: groupedAway.entries.map((e) => Text(
                '${e.key} ${e.value.join(", ")}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCommentary(BuildContext context) {
    final match = widget.match;
    final summaryAsync = ref.watch(matchDetailsProvider(match.id));
    return summaryAsync.when(
      data: (summary) {
        if (summary.commentaries.isEmpty) return const SizedBox();
        // Reverse: most recent first, take top 3
        final top3 = summary.commentaries.reversed.take(3).toList();
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'MINUTO A MINUTO',
                style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              ...top3.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.time.isNotEmpty)
                      SizedBox(
                        width: 40,
                        child: Text(
                          c.time,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        c.text,
                        style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchDetailsScreen(match: match, initialTabIndex: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Text('Ver más', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (_, __) => const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final home = match.homeTeam;
    final away = match.awayTeam;

    String displayGroupName = match.groupName ?? 'Fase de Grupos';
    final groupsAsync = ref.watch(groupsProvider);
    if (groupsAsync.hasValue && home != null) {
      for (var group in groupsAsync.value!) {
        if (group.standings.any((s) => s.team.id == home.id)) {
          displayGroupName = group.name.replaceAll('Group', 'Grupo').replaceAll('group', 'Grupo');
          break;
        }
      }
    }

    final homeIsWinner = match.status == MatchStatus.finished &&
        (home?.winner == true ||
            (home?.score != null &&
                away?.score != null &&
                int.tryParse(home!.score!) != null &&
                int.tryParse(away!.score!) != null &&
                int.parse(home!.score!) > int.parse(away!.score!)));
    final awayIsWinner = match.status == MatchStatus.finished &&
        (away?.winner == true ||
            (home?.score != null &&
                away?.score != null &&
                int.tryParse(home!.score!) != null &&
                int.tryParse(away!.score!) != null &&
                int.parse(away!.score!) > int.parse(home!.score!)));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: match)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header info
            Column(
              children: [
                Text(
                  'Fase de Grupos · ${AppDateUtils.formatShortDay(match.date)} ${AppDateUtils.formatDayNumber(match.date)} ${AppDateUtils.formatTime(match.date)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                if (displayGroupName != 'Fase de Grupos')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      displayGroupName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Teams and score/time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Home Team
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      TeamFlag(
                        logoUrl: home?.logoUrl,
                        teamName: home?.displayName ?? 'TBD',
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        home?.displayName ?? 'Por definir',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: homeIsWinner ? AppColors.primary : Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Info
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      if (match.status == MatchStatus.upcoming)
                        CountdownWidget(targetDate: match.date)
                      else if (match.status == MatchStatus.finished)
                        Column(
                          children: [
                            const Text(
                              'FINALIZADO',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              AppDateUtils.formatTime(match.date),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      else
                        LiveBadge(
                          matchId: match.id,
                          clock: match.displayClock,
                          clockSeconds: match.clockSeconds,
                          period: match.period,
                          isTicking: match.isTicking,
                          isHalftime: match.isHalftime,
                        ),
                      const SizedBox(height: 12),
                      if (match.status != MatchStatus.upcoming)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${home?.score ?? "0"}',
                              style: TextStyle(
                                color: homeIsWinner ? AppColors.primary : Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              ' - ',
                              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${away?.score ?? "0"}',
                              style: TextStyle(
                                color: awayIsWinner ? AppColors.primary : Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Away Team
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      TeamFlag(
                        logoUrl: away?.logoUrl,
                        teamName: away?.displayName ?? 'TBD',
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        away?.displayName ?? 'Por definir',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: awayIsWinner ? AppColors.primary : Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (match.status == MatchStatus.live || match.status == MatchStatus.finished)
              _buildGoals(),

            if (match.status == MatchStatus.live)
              _buildLiveCommentary(context),

            const SizedBox(height: 24),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 16),

            // Venue
            Text(
              '${match.venue?.fullName ?? "Estadio por definir"} · ${match.venue?.city ?? ""}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
