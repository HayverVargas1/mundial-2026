// lib/core/constants/espn_constants.dart

class EspnConstants {
  EspnConstants._();

  // Base URLs
  static const String siteApiBase = 'https://site.api.espn.com';
  static const String siteApiV2 = '$siteApiBase/apis/site/v2';
  static const String siteApiV2Alt = '$siteApiBase/apis/v2';

  // Soccer league slug for FIFA World Cup 2026
  static const String sport = 'soccer';
  static const String league = 'fifa.world';

  // Endpoints
  static String get scoreboardUrl =>
      '$siteApiV2/sports/$sport/$league/scoreboard?lang=es&region=co';

  static String scoreboardByDate(String date) =>
      '$siteApiV2/sports/$sport/$league/scoreboard?dates=$date&lang=es&region=co';

  static String get standingsUrl =>
      '$siteApiV2Alt/sports/$sport/$league/standings?lang=es&region=co';

  static String get teamsUrl =>
      '$siteApiV2/sports/$sport/$league/teams';

  static String summaryUrl(String eventId) =>
      '$siteApiV2/sports/$sport/$league/summary?event=$eventId';

  static String get newsUrl =>
      '$siteApiV2/sports/$sport/$league/news';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const int maxRetries = 3;

  // Cache durations
  static const Duration scoreboardCacheDuration = Duration(minutes: 2);
  static const Duration standingsCacheDuration = Duration(minutes: 10);
  static const Duration teamsCacheDuration = Duration(hours: 6);
}
