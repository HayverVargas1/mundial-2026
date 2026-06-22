import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/statistics');
  final res = await http.get(url);
  if (res.statusCode == 200) {
    final data = json.decode(res.body);
    print('Keys in data: \${data.keys}');
    if (data['stats'] != null) {
      final stats = data['stats'] as List;
      print('Number of stat categories: \${stats.length}');
      if (stats.isNotEmpty) {
        print("First stat category: \${stats[0]['name']}");
        print("First stat description: \${stats[0]['description']}");
      }
    }
  }
}
