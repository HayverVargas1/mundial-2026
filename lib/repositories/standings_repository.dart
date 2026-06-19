import '../models/group_model.dart';
import '../services/standings_service.dart';

class StandingsRepository {
  final StandingsService _service;

  StandingsRepository(this._service);

  Future<List<GroupModel>> getGroups() {
    return _service.getGroups();
  }
}
