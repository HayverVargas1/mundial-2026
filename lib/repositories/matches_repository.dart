import '../models/match_model.dart';
import '../services/matches_service.dart';

class MatchesRepository {
  final MatchesService _service;

  MatchesRepository(this._service);

  Future<List<MatchModel>> getMatches([String? dateYYYYMMDD]) {
    return _service.getMatches(dateYYYYMMDD);
  }
}
