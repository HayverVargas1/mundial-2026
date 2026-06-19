import 'team_model.dart';

class StandingModel {
  final TeamModel team;
  final int matchesPlayed;
  final int matchesWon;
  final int matchesDrawn;
  final int matchesLost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;
  final String note;

  StandingModel({
    required this.team,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.matchesDrawn,
    required this.matchesLost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
    required this.note,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    final teamJson = json['team'] ?? {};
    final stats = json['stats'] as List? ?? [];
    
    int getStat(String name) {
      try {
        final stat = stats.firstWhere((s) => s['name'] == name, orElse: () => null);
        if (stat != null) {
          return int.tryParse(stat['displayValue']?.toString() ?? '0') ?? 0;
        }
      } catch (e) {
        // ignore
      }
      return 0;
    }

    return StandingModel(
      team: TeamModel.fromJson(teamJson),
      matchesPlayed: getStat('gamesPlayed'),
      matchesWon: getStat('wins'),
      matchesDrawn: getStat('ties'),
      matchesLost: getStat('losses'),
      goalsFor: getStat('pointsFor'),
      goalsAgainst: getStat('pointsAgainst'),
      goalDifference: getStat('pointDifferential'),
      points: getStat('points'),
      note: json['note']?['description'] ?? '',
    );
  }
}
