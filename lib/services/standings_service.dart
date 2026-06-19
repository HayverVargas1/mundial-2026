import '../core/constants/espn_constants.dart';
import '../models/group_model.dart';
import 'espn_service.dart';

class StandingsService {
  final EspnService _api;

  StandingsService(this._api);

  Future<List<GroupModel>> getGroups() async {
    final url = EspnConstants.standingsUrl;
    final data = await _api.get(url);
    
    final children = data['children'] as List? ?? [];
    
    // Group A, Group B, etc are usually in children for tournaments
    return children.map((g) => GroupModel.fromJson(g)).toList();
  }
}
