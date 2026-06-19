import 'team_model.dart';

class GoalModel {
  final String teamId;
  final String playerName;
  final String minute;
  final bool isPenalty;

  GoalModel({
    required this.teamId,
    required this.playerName,
    required this.minute,
    required this.isPenalty,
  });
}

class MatchModel {
  final String id;
  final DateTime date;
  final String name;
  final String shortName;
  final MatchStatus status;
  final Venue? venue;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final String? groupName;
  final List<GoalModel> goals;
  final String? displayClock;
  final double? clockSeconds;
  final int period;
  final bool isTicking;
  final bool isHalftime;

  MatchModel({
    required this.id,
    required this.date,
    required this.name,
    required this.shortName,
    required this.status,
    this.venue,
    this.homeTeam,
    this.awayTeam,
    this.groupName,
    this.goals = const [],
    this.displayClock,
    this.clockSeconds,
    this.period = 1,
    this.isTicking = false,
    this.isHalftime = false,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    final competition = json['competitions'][0];
    
    MatchStatus status = MatchStatus.upcoming;
    final statusId = competition['status']?['type']?['id']?.toString();
    final state = competition['status']?['type']?['state']?.toString();

    if (state == 'post' || statusId == '3' || statusId == '28') {
      status = MatchStatus.finished;
    } else if (state == 'in' || statusId == '2') {
      status = MatchStatus.live;
    } else if (state == 'pre' || statusId == '1') {
      status = MatchStatus.upcoming;
    }

    Venue? venue;
    if (competition['venue'] != null) {
      venue = Venue.fromJson(competition['venue']);
    }

    TeamModel? homeTeam;
    TeamModel? awayTeam;
    if (competition['competitors'] != null) {
      for (var comp in competition['competitors']) {
        final isHome = comp['homeAway'] == 'home';
        final teamJson = (comp['team'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        final teamData = <String, dynamic>{
          ...teamJson,
          if (comp['score'] != null) 'score': comp['score'],
          if (comp['winner'] != null) 'winner': comp['winner'],
        };
        final team = TeamModel.fromJson(teamData);
        if (isHome) {
          homeTeam = team;
        } else {
          awayTeam = team;
        }
      }
    }

    final List<GoalModel> goalsList = [];
    if (competition['details'] != null) {
      for (var detail in competition['details']) {
        if (detail['scoringPlay'] == true && detail['shootout'] != true) {
          final teamId = detail['team']?['id']?.toString() ?? '';
          final clock = detail['clock']?['displayValue']?.toString() ?? '';
          String playerName = 'Unknown';
          if (detail['athletesInvolved'] != null && (detail['athletesInvolved'] as List).isNotEmpty) {
            playerName = detail['athletesInvolved'][0]['shortName'] ?? detail['athletesInvolved'][0]['displayName'] ?? 'Unknown';
          }
          final isPenalty = detail['type']?['text']?.toString().toLowerCase().contains('penalty') ?? false;
          goalsList.add(GoalModel(
            teamId: teamId,
            playerName: playerName,
            minute: clock,
            isPenalty: isPenalty,
          ));
        }
      }
    }

    String? groupName;
    if (json['notes'] != null && (json['notes'] as List).isNotEmpty) {
      groupName = json['notes'][0]['headline'];
    } else if (competition['notes'] != null && (competition['notes'] as List).isNotEmpty) {
      groupName = competition['notes'][0]['headline'];
    } else {
      groupName = 'Fase de Grupos';
    }

    String? displayClock;
    double? clockSeconds;
    int period = 1;
    bool isTicking = false;
    bool isHalftime = false;
    
    if (status == MatchStatus.live || status == MatchStatus.finished) {
      if (competition['status']?['displayClock'] != null) {
        displayClock = competition['status']['displayClock'].toString();
      }
      if (competition['status']?['clock'] != null) {
        clockSeconds = double.tryParse(competition['status']['clock'].toString());
      }
      if (competition['status']?['period'] != null) {
        period = int.tryParse(competition['status']['period'].toString()) ?? 1;
      }
      
      if (status == MatchStatus.live) {
        final statusName = competition['status']?['type']?['name']?.toString() ?? '';
        final desc = competition['status']?['type']?['description']?.toString().toLowerCase() ?? '';
        
        isTicking = statusName.contains('HALF') || statusName.contains('PROGRESS') || statusName.contains('EXTRA');
        if (desc.contains('halftime') || desc.contains('half-time') || desc.contains('descanso') || statusName == 'STATUS_HALFTIME') {
          isTicking = false;
          isHalftime = true;
        }
      }
    }

    // Force score to be at least the number of goals found in details,
    // to fix ESPN API delays where play-by-play updates before the main score.
    if (homeTeam != null) {
      final homeGoalsCount = goalsList.where((g) => g.teamId == homeTeam!.id).length;
      final currentScore = int.tryParse(homeTeam!.score ?? '0') ?? 0;
      if (homeGoalsCount > currentScore) {
        homeTeam = homeTeam!.copyWith(score: homeGoalsCount.toString());
      }
    }
    if (awayTeam != null) {
      final awayGoalsCount = goalsList.where((g) => g.teamId == awayTeam!.id).length;
      final currentScore = int.tryParse(awayTeam!.score ?? '0') ?? 0;
      if (awayGoalsCount > currentScore) {
        awayTeam = awayTeam!.copyWith(score: awayGoalsCount.toString());
      }
    }

    return MatchModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      shortName: json['shortName'],
      status: status,
      venue: venue,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      groupName: groupName,
      goals: goalsList,
      displayClock: displayClock,
      clockSeconds: clockSeconds,
      period: period,
      isTicking: isTicking,
      isHalftime: isHalftime,
    );
  }
}

enum MatchStatus { upcoming, live, finished, unknown }

class Venue {
  final String id;
  final String fullName;
  final String? city;
  final String? state;

  Venue({
    required this.id,
    required this.fullName,
    this.city,
    this.state,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      city: json['address']?['city'],
      state: json['address']?['state'],
    );
  }
}
