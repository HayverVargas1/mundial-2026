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
    final summaryData = json.decode(summaryRes.body);
    print('Summary keys: ${summaryData.keys}');
    if (summaryData['commentary'] != null) {
      final commentary = summaryData['commentary'] as List;
      print('Commentary length: ${commentary.length}');
      if (commentary.isNotEmpty) {
        print('First commentary: ${commentary[0]['text']}');
      }
    } else if (summaryData['plays'] != null) {
      final plays = summaryData['plays'] as List;
      print('Plays length: ${plays.length}');
      if (plays.isNotEmpty) {
        print('First play: ${plays[0]['text']}');
      }
    } else {
      print('No commentary or plays found.');
    }
  }
}
