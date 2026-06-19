import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/team_model.dart';
import '../../models/roster_model.dart';
import '../../services/espn_service.dart';

final teamsProvider = FutureProvider<List<TeamModel>>((ref) async {
  final service = EspnService();
  final data = await service.get('https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/teams?lang=es&region=es');
  
  final sports = data['sports'] as List? ?? [];
  if (sports.isEmpty) return [];
  
  final leagues = sports[0]['leagues'] as List? ?? [];
  if (leagues.isEmpty) return [];
  
  final teamsJson = leagues[0]['teams'] as List? ?? [];
  return teamsJson.map((t) => TeamModel.fromJson(t['team'])).toList();
});

final rosterProvider = FutureProvider.family<RosterModel, String>((ref, teamId) async {
  final service = EspnService();
  final data = await service.get('https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/teams/$teamId/roster?lang=es&region=es');
  return RosterModel.fromJson(data);
});
