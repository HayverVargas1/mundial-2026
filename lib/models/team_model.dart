class TeamModel {
  final String id;
  final String abbreviation;
  final String displayName;
  final String? shortDisplayName;
  final String? color;
  final String? alternateColor;
  final String? logoUrl;
  final String? score;
  final bool? winner;

  TeamModel({
    required this.id,
    required this.abbreviation,
    required this.displayName,
    this.shortDisplayName,
    this.color,
    this.alternateColor,
    this.logoUrl,
    this.score,
    this.winner,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    String? logo;
    if (json['logo'] != null) {
      logo = json['logo'];
    } else if (json['logos'] != null && (json['logos'] as List).isNotEmpty) {
      logo = json['logos'][0]['href'];
    }

    return TeamModel(
      id: json['id'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      shortDisplayName: json['shortDisplayName'],
      color: json['color'],
      alternateColor: json['alternateColor'],
      logoUrl: logo,
      score: json['score']?.toString(),
      winner: json['winner'],
    );
  }

  TeamModel copyWith({
    String? id,
    String? abbreviation,
    String? displayName,
    String? shortDisplayName,
    String? color,
    String? alternateColor,
    String? logoUrl,
    String? score,
    bool? winner,
  }) {
    return TeamModel(
      id: id ?? this.id,
      abbreviation: abbreviation ?? this.abbreviation,
      displayName: displayName ?? this.displayName,
      shortDisplayName: shortDisplayName ?? this.shortDisplayName,
      color: color ?? this.color,
      alternateColor: alternateColor ?? this.alternateColor,
      logoUrl: logoUrl ?? this.logoUrl,
      score: score ?? this.score,
      winner: winner ?? this.winner,
    );
  }
}
