import 'commentary_model.dart';

class MatchSummaryModel {
  final List<TeamStat> homeStats;
  final List<TeamStat> awayStats;
  final List<PlayerRoster> homeRoster;
  final List<PlayerRoster> awayRoster;
  final String homeFormation;
  final String awayFormation;
  final List<CommentaryModel> commentaries;

  MatchSummaryModel({
    this.homeStats = const [],
    this.awayStats = const [],
    this.homeRoster = const [],
    this.awayRoster = const [],
    this.homeFormation = '',
    this.awayFormation = '',
    this.commentaries = const [],
  });

  factory MatchSummaryModel.fromJson(Map<String, dynamic> json) {
    List<TeamStat> homeS = [];
    List<TeamStat> awayS = [];
    
    if (json['boxscore'] != null && json['boxscore']['teams'] != null) {
      final teams = json['boxscore']['teams'] as List;
      for (var teamData in teams) {
        final isHome = teamData['homeAway'] == 'home';
        final statsList = teamData['statistics'] as List? ?? [];
        List<TeamStat> parsedStats = statsList.map((s) => TeamStat(
          name: s['name'] ?? '',
          displayValue: s['displayValue'] ?? '0',
          label: s['label'] ?? s['name'] ?? '',
        )).toList();
        
        if (isHome) {
          homeS = parsedStats;
        } else {
          awayS = parsedStats;
        }
      }
    }

    List<PlayerRoster> homeR = [];
    List<PlayerRoster> awayR = [];
    String homeF = '';
    String awayF = '';

    if (json['rosters'] != null) {
      final rosters = json['rosters'] as List;
      for (var rosterData in rosters) {
        final isHome = rosterData['homeAway'] == 'home';
        final formation = rosterData['formation']?.toString() ?? '';
        final rosterList = rosterData['roster'] as List? ?? [];
        
        List<PlayerRoster> parsedRoster = rosterList.map((p) {
          final athlete = p['athlete'] ?? {};
          return PlayerRoster(
            id: athlete['id'] ?? '',
            displayName: athlete['displayName'] ?? '',
            shortName: athlete['shortName'] ?? '',
            jersey: athlete['jersey'] ?? '',
            position: p['position']?['name'] ?? p['position']?['abbreviation'] ?? '',
            starter: p['starter'] == true,
            substitutedIn: p['substitutedIn'] == true,
          );
        }).toList();

        if (isHome) {
          homeR = parsedRoster;
          homeF = formation;
        } else {
          awayR = parsedRoster;
          awayF = formation;
        }
      }
    }

    List<CommentaryModel> parsedCommentaries = [];
    if (json['commentary'] != null) {
      final commList = json['commentary'] as List;
      parsedCommentaries = commList.map((c) => CommentaryModel.fromJson(c)).toList();
    } else if (json['plays'] != null) {
      final playsList = json['plays'] as List;
      parsedCommentaries = playsList.map((p) => CommentaryModel.fromJson(p)).toList();
    }

    return MatchSummaryModel(
      homeStats: homeS,
      awayStats: awayS,
      homeRoster: homeR,
      awayRoster: awayR,
      homeFormation: homeF,
      awayFormation: awayF,
      commentaries: parsedCommentaries,
    );
  }
}

class TeamStat {
  final String name;
  final String displayValue;
  final String label;

  TeamStat({required this.name, required this.displayValue, required this.label});
}

class PlayerRoster {
  final String id;
  final String displayName;
  final String shortName;
  final String jersey;
  final String position;
  final bool starter;
  final bool substitutedIn;

  PlayerRoster({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.jersey,
    required this.position,
    required this.starter,
    required this.substitutedIn,
  });
}
