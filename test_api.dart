import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/scoreboard');
  final res = await http.get(url);
  final data = json.decode(res.body);
  final events = data['events'] as List?;
  if (events != null && events.isNotEmpty) {
    print(json.encode(events[0]));
  } else {
    print('No events');
  }
}
