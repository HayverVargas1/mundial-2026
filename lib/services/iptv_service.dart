import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/channel_model.dart';

class IptvService {
  static const String playlistUrl = 'https://iptv-org.github.io/iptv/categories/sports.m3u';

  Future<List<ChannelModel>> fetchSportsChannels() async {
    final List<ChannelModel> allChannels = [];

    // 1. Load local tv.m3u channels
    try {
      final localM3u = await rootBundle.loadString('assets/data/tv.m3u');
      allChannels.addAll(_parseM3u(localM3u));
    } catch (e) {
      // Ignore local error
    }

    // 2. Load remote iptv-org channels
    try {
      final response = await http.get(Uri.parse(playlistUrl));
      if (response.statusCode == 200) {
        allChannels.addAll(_parseM3u(response.body));
      }
    } catch (e) {
      // Return empty on error
    }
    
    // Remove duplicates
    final Map<String, ChannelModel> uniqueChannels = {};
    for (var c in allChannels) {
      uniqueChannels[c.streamUrl] = c;
    }
    
    return _sortAndFilter(uniqueChannels.values.toList());
  }

  List<ChannelModel> _parseM3u(String m3u) {
    final List<ChannelModel> channels = [];
    final lines = m3u.split('\n');
    
    String currentName = '';
    String currentLogo = '';
    String currentGroup = '';

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF:')) {
        final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
        currentLogo = logoMatch != null ? logoMatch.group(1) ?? '' : '';

        final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
        currentGroup = groupMatch != null ? groupMatch.group(1) ?? 'Sports' : 'Sports';

        final commaIndex = line.lastIndexOf(',');
        if (commaIndex != -1 && commaIndex < line.length - 1) {
          currentName = line.substring(commaIndex + 1).trim();
        }
      } else if (!line.startsWith('#')) {
        if (currentName.isNotEmpty && line.startsWith('http')) {
          channels.add(ChannelModel(
            name: currentName,
            logoUrl: currentLogo,
            group: currentGroup,
            streamUrl: line,
          ));
        }
        currentName = '';
        currentLogo = '';
        currentGroup = '';
      }
    }
    
    return channels;
  }

  List<ChannelModel> _sortAndFilter(List<ChannelModel> channels) {
    var validChannels = channels.toList();
    
    final List<String> worldCupKeywords = [
      'america', 'américa', 'arena sport', 'tyc', 'caracol', 'rcn', 'telemundo', 'fox sports', 'directv', 'dsports',
      'azteca', 'televisa', 'tudn', 'bein', 'gol', 'mundial', 'fifa'
    ];
    
    validChannels.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      
      bool aIsWorldCup = worldCupKeywords.any((k) => aName.contains(k));
      bool bIsWorldCup = worldCupKeywords.any((k) => bName.contains(k));
      
      if (aIsWorldCup && !bIsWorldCup) return -1;
      if (!aIsWorldCup && bIsWorldCup) return 1;
      return a.name.compareTo(b.name);
    });
    
    return validChannels;
  }
}
