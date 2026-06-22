import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_model.dart';
import '../providers/app_providers.dart';
import '../screens/match_details/match_details_screen.dart';
import '../models/team_model.dart';

/// Navigates to MatchDetailsScreen for the next upcoming match of a team.
/// Used from the Groups screen when tapping a team row.
void navigateToNextMatch(BuildContext context, WidgetRef ref, TeamModel team) {
  final allMatchesAsync = ref.read(allMatchesProvider);
  allMatchesAsync.whenData((matches) {
    // Find next upcoming or live match for this team
    final teamMatches = matches.where((m) =>
      (m.homeTeam?.id == team.id || m.awayTeam?.id == team.id) &&
      m.status != MatchStatus.finished
    ).toList();

    if (teamMatches.isEmpty) {
      // If no upcoming match, find the most recent finished match
      final finishedMatches = matches.where((m) =>
        (m.homeTeam?.id == team.id || m.awayTeam?.id == team.id) &&
        m.status == MatchStatus.finished
      ).toList();
      
      if (finishedMatches.isNotEmpty) {
        finishedMatches.sort((a, b) => b.date.compareTo(a.date));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: finishedMatches.first)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay partidos disponibles para este equipo.')),
        );
      }
      return;
    }

    teamMatches.sort((a, b) => a.date.compareTo(b.date));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchDetailsScreen(match: teamMatches.first)),
    );
  });
}
