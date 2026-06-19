import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/all/scoreboard');
  final res = await http.get(url);
  final data = json.decode(res.body);
  if ((data['events'] as List).isNotEmpty) {
    final eventId = data['events'][0]['id'];
    print('Event ID: $eventId');
    final summaryRes = await http.get(Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/all/summary?event=$eventId'));
    print('Summary keys: ${json.decode(summaryRes.body).keys}');
    print('Boxscore: ${json.decode(summaryRes.body)['boxscore']?.keys}');
    print('Rosters: ${json.decode(summaryRes.body)['rosters']?.map((r) => r['team']['displayName']).toList()}');
  }
}
