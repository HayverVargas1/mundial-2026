import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/espn_constants.dart';
import '../models/match_model.dart';
import 'espn_service.dart';

class MatchesService {
  final EspnService _api;

  MatchesService(this._api);

  Future<List<MatchModel>> getMatches([String? dateYYYYMMDD]) async {
    final url = dateYYYYMMDD != null
        ? EspnConstants.scoreboardByDate(dateYYYYMMDD)
        : EspnConstants.scoreboardUrl;

    final data = await _api.get(url);
    
    // Save to cache if fetching the full tournament
    if (dateYYYYMMDD == '20260611-20260719') {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_all_matches', jsonEncode(data));
        await prefs.setInt('last_espn_fetch_time', DateTime.now().millisecondsSinceEpoch);
      } catch (e) {
        // ignore
      }
    }

    final events = data['events'] as List? ?? [];
    return events.map((e) => MatchModel.fromJson(e)).toList();
  }

  Future<List<MatchModel>?> getCachedMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_all_matches');
      if (cached != null) {
        final data = jsonDecode(cached);
        final events = data['events'] as List? ?? [];
        return events.map((e) => MatchModel.fromJson(e)).toList();
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}
