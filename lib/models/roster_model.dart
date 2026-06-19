class RosterModel {
  final List<PlayerModel> athletes;
  final List<CoachModel> coaches;

  RosterModel({
    required this.athletes,
    required this.coaches,
  });

  factory RosterModel.fromJson(Map<String, dynamic> json) {
    final athletesList = json['athletes'] as List? ?? [];
    final coachList = json['coach'] as List? ?? [];

    return RosterModel(
      athletes: athletesList.map((e) => PlayerModel.fromJson(e)).toList(),
      coaches: coachList.map((e) => CoachModel.fromJson(e)).toList(),
    );
  }
}

class PlayerModel {
  final String id;
  final String firstName;
  final String lastName;
  final String displayName;
  final String shortName;
  final int? age;
  final String? jersey;
  final String positionName;
  final String positionAbbrev;

  PlayerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.shortName,
    this.age,
    this.jersey,
    required this.positionName,
    required this.positionAbbrev,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final position = json['position'] ?? {};
    return PlayerModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? json['fullName'] ?? '',
      shortName: json['shortName'] ?? '',
      age: json['age'],
      jersey: json['jersey'],
      positionName: position['displayName'] ?? position['name'] ?? 'Unknown',
      positionAbbrev: position['abbreviation'] ?? '?',
    );
  }
}

class CoachModel {
  final String id;
  final String firstName;
  final String lastName;

  CoachModel({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }
}
