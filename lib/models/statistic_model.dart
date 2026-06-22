class StatisticCategoryModel {
  final String name;
  final String displayName;
  final String shortDisplayName;
  final String description;
  final List<StatisticLeaderModel> leaders;

  StatisticCategoryModel({
    required this.name,
    required this.displayName,
    required this.shortDisplayName,
    required this.description,
    required this.leaders,
  });

  factory StatisticCategoryModel.fromJson(Map<String, dynamic> json) {
    final leadersList = json['leaders'] as List? ?? [];
    return StatisticCategoryModel(
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      shortDisplayName: json['shortDisplayName'] ?? '',
      description: json['description'] ?? '',
      leaders: leadersList.map((e) => StatisticLeaderModel.fromJson(e)).toList(),
    );
  }
}

class StatisticLeaderModel {
  final String displayValue;
  final double value;
  final String athleteId;
  final String athleteName;
  final String athleteHeadshot;
  final String teamId;
  final String teamName;
  final String teamLogo;
  final String athletePosition;

  StatisticLeaderModel({
    required this.displayValue,
    required this.value,
    required this.athleteId,
    required this.athleteName,
    required this.athleteHeadshot,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
    required this.athletePosition,
  });

  factory StatisticLeaderModel.fromJson(Map<String, dynamic> json) {
    final athlete = json['athlete'] ?? {};
    final team = json['team'] ?? {};
    final position = athlete['position'] ?? {};
    
    String athleteHeadshot = '';
    if (athlete['headshot'] != null && athlete['headshot']['href'] != null) {
      athleteHeadshot = athlete['headshot']['href'];
    }

    String teamLogo = '';
    if (team['logos'] != null && team['logos'] is List && team['logos'].isNotEmpty) {
      teamLogo = team['logos'][0]['href'] ?? '';
    } else if (team['logo'] != null) {
      teamLogo = team['logo'];
    }

    return StatisticLeaderModel(
      displayValue: json['displayValue'] ?? json['value']?.toString() ?? '0',
      value: (json['value'] ?? 0).toDouble(),
      athleteId: athlete['id'] ?? '',
      athleteName: athlete['displayName'] ?? athlete['fullName'] ?? 'Unknown',
      athleteHeadshot: athleteHeadshot,
      teamId: team['id'] ?? '',
      teamName: team['displayName'] ?? team['name'] ?? '',
      teamLogo: teamLogo,
      athletePosition: position['abbreviation'] ?? position['name'] ?? '',
    );
  }
}
