// lib/core/constants/app_strings.dart

class AppStrings {
  AppStrings._();

  static const String appName = 'Mundial 26';
  static const String tournamentName = 'COPA MUNDIAL DE LA FIFA';
  static const String tournamentYear = '2026';

  // Navigation
  static const String navMatches = 'Partidos';
  static const String navGroups = 'Grupos';
  static const String navBracket = 'Llaves';
  static const String navAlerts = 'Alertas';

  // Matches Screen
  static const String nextMatch = 'PRÓXIMO';
  static const String liveMatch = 'EN VIVO';
  static const String finishedMatch = 'FINALIZADO';
  static const String startingIn = 'EMPIEZA EN';
  static const String today = 'HOY';
  static const String tomorrow = 'MAÑANA';
  static const String vs = 'VS';

  // Groups Screen
  static const String groups = 'Grupos';
  static const String position = 'P';
  static const String team = 'Equipo';
  static const String played = 'PJ';
  static const String won = 'PG';
  static const String drawn = 'PE';
  static const String lost = 'PP';
  static const String goalsFor = 'GF';
  static const String goalsAgainst = 'GC';
  static const String goalDiff = 'DG';
  static const String points = 'PTS';

  // Bracket Screen
  static const String roundOf32 = 'Ronda 32';
  static const String roundOf16 = 'Octavos';
  static const String quarterFinals = 'Cuartos';
  static const String semiFinals = 'Semifinal';
  static const String thirdPlace = 'Tercer lugar';
  static const String finalMatch = 'Final';

  // Alerts Screen
  static const String alertsTitle = 'Notificaciones';
  static const String alertMatchStart = 'Notificar 15 min antes';
  static const String alertMatchStartSub = 'Recibe una alerta antes de que empiece el partido';
  static const String alertMatchStarted = 'Cuando inicie el partido';
  static const String alertMatchStartedSub = 'Recibe una alerta en el momento del saque inicial';
  static const String alertGoal = 'Gol';
  static const String alertGoalSub = 'Notificar cuando se marque un gol';
  static const String alertHalfTime = 'Descanso';
  static const String alertHalfTimeSub = 'Notificar al inicio del descanso';
  static const String alertFinalResult = 'Resultado final';
  static const String alertFinalResultSub = 'Notificar al finalizar el partido';

  // Errors
  static const String errorNoInternet = 'Sin conexión a internet';
  static const String errorLoadFailed = 'Error al cargar los datos';
  static const String errorRetry = 'Reintentar';
  static const String errorNoMatches = 'No hay partidos disponibles';

  // Days
  static const List<String> weekDays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  static const List<String> months = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
  ];
  static const List<String> fullMonths = [
    'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
    'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
  ];
}
