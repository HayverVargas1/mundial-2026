import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/all/scoreboard'));
  final data = json.decode(res.body);
  for (var e in data['events']) {
    print(e['competitions'][0]['status']['type']);
  }
}
