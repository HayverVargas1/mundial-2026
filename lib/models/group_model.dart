import 'standing_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String abbreviation;
  final List<StandingModel> standings;

  GroupModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.standings,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final standingsJson = json['standings']?['entries'] as List? ?? [];
    final List<StandingModel> parsedStandings = standingsJson.map((s) => StandingModel.fromJson(s)).toList();
    
    // Explicitly sort just in case API returns them out of order
    parsedStandings.sort((a, b) {
      if (b.points != a.points) {
        return b.points.compareTo(a.points);
      }
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return GroupModel(
      id: json['id'] ?? json['uid'] ?? '',
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      standings: parsedStandings,
    );
  }
}
