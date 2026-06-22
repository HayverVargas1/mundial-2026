import '../core/constants/espn_constants.dart';
import '../models/statistic_model.dart';
import 'espn_service.dart';

class StatisticsService {
  final EspnService _api;

  StatisticsService(this._api);

  Future<List<StatisticCategoryModel>> getStatistics() async {
    final url = EspnConstants.statisticsUrl;
    final data = await _api.get(url);
    
    final statsList = data['stats'] as List? ?? [];
    return statsList.map((e) => StatisticCategoryModel.fromJson(e)).toList();
  }
}
