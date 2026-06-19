import 'package:flutter/material.dart';
import '../../models/match_model.dart';
import '../../models/match_summary_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/team_flag.dart';

class MatchRostersView extends StatelessWidget {
  final MatchSummaryModel summary;
  final MatchModel match;

  const MatchRostersView({Key? key, required this.summary, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (summary.homeRoster.isEmpty && summary.awayRoster.isEmpty) {
      return const Center(child: Text('Alineaciones no disponibles aún', style: TextStyle(color: AppColors.textSecondary)));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Home Roster
        Expanded(
          child: _buildTeamRoster(
            teamName: match.homeTeam?.displayName ?? 'Local',
            formation: summary.homeFormation,
            roster: summary.homeRoster,
            isHome: true,
            logoUrl: match.homeTeam?.logoUrl,
          ),
        ),
        Container(width: 1, color: AppColors.border),
        // Away Roster
        Expanded(
          child: _buildTeamRoster(
            teamName: match.awayTeam?.displayName ?? 'Visitante',
            formation: summary.awayFormation,
            roster: summary.awayRoster,
            isHome: false,
            logoUrl: match.awayTeam?.logoUrl,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamRoster({
    required String teamName,
    required String formation,
    required List<PlayerRoster> roster,
    required bool isHome,
    String? logoUrl,
  }) {
    final starters = roster.where((p) => p.starter).toList();
    final bench = roster.where((p) => !p.starter).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TeamFlag(logoUrl: logoUrl, teamName: teamName, size: 40),
            const SizedBox(height: 8),
            Text(
              teamName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (formation.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Text(
                  formation,
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
        const SizedBox(height: 16),
        const Text('TITULARES', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        ...starters.map((p) => _buildPlayerRow(p)).toList(),
        
        const SizedBox(height: 24),
        const Text('SUPLENTES', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        ...bench.map((p) => _buildPlayerRow(p)).toList(),
      ],
    );
  }

  Widget _buildPlayerRow(PlayerRoster p) {
    String translatedPos = p.position;
    final posUpper = p.position.toUpperCase();
    
    if (posUpper.contains('GOALKEEPER') || posUpper == 'G' || posUpper == 'GK') {
      translatedPos = 'Portero';
    } else if (posUpper.contains('CENTER LEFT DEFENDER')) {
      translatedPos = 'Defensa Central Izquierdo';
    } else if (posUpper.contains('CENTER RIGHT DEFENDER')) {
      translatedPos = 'Defensa Central Derecho';
    } else if (posUpper.contains('LEFT BACK')) {
      translatedPos = 'Lateral Izquierdo';
    } else if (posUpper.contains('RIGHT BACK')) {
      translatedPos = 'Lateral Derecho';
    } else if (posUpper.contains('CENTER MIDFIELDER')) {
      translatedPos = 'Mediocampista Central';
    } else if (posUpper.contains('LEFT MIDFIELDER')) {
      translatedPos = 'Mediocampista Izquierdo';
    } else if (posUpper.contains('RIGHT MIDFIELDER')) {
      translatedPos = 'Mediocampista Derecho';
    } else if (posUpper.contains('LEFT FORWARD')) {
      translatedPos = 'Extremo Izquierdo';
    } else if (posUpper.contains('RIGHT FORWARD')) {
      translatedPos = 'Extremo Derecho';
    } else if (posUpper.contains('DEFENDER') || posUpper == 'D' || posUpper == 'DEF') {
      translatedPos = 'Defensa';
    } else if (posUpper.contains('MIDFIELDER') || posUpper == 'M' || posUpper == 'MID') {
      translatedPos = 'Mediocampista';
    } else if (posUpper.contains('FORWARD') || posUpper.contains('STRIKER') || posUpper.contains('ATTACKER') || posUpper == 'F' || posUpper == 'ATT') {
      translatedPos = 'Delantero';
    } else if (posUpper.contains('SUBSTITUTE') || posUpper == 'S' || posUpper == 'SUB') {
      translatedPos = 'Suplente';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                p.jersey,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.shortName.isNotEmpty ? p.shortName : p.displayName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  translatedPos,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          if (p.substitutedIn)
            const Icon(Icons.arrow_circle_up, color: AppColors.live, size: 16),
        ],
      ),
    );
  }
}
