import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../models/match_model.dart';
import '../providers/app_providers.dart';
import '../core/utils/date_utils.dart';
import 'notification_service.dart';

class PollingService {
  static final PollingService _instance = PollingService._internal();
  factory PollingService() => _instance;
  PollingService._internal();

  Timer? _timer;
  Timer? _tickerTimer;
  ProviderContainer? _container;
  
  // Track previous state of goals and started matches to avoid spamming
  Map<String, int> _matchGoals = {};
  Set<String> _startedMatches = {};
  Set<String> _liveMatchIds = {};
  Set<String> _15MinMatches = {};
  Set<String> _halfTimeMatches = {};
  Set<String> _finishedMatches = {};
  
  List<String> _mutedMatches = [];
  bool _sendNotifications = true;
  bool _updateWidget = true;
  bool _isFirstPoll = true;
  SharedPreferences? _prefs;

  Future<void> start(ProviderContainer container, {bool sendNotifications = true, bool updateWidget = true}) async {
    _container = container;
    _sendNotifications = sendNotifications;
    _updateWidget = updateWidget;
    _timer?.cancel();
    _tickerTimer?.cancel();
    
    // Load persisted state
    _prefs = await SharedPreferences.getInstance();
    final goalsJson = _prefs!.getString('matchGoals');
    if (goalsJson != null) {
      _matchGoals = Map<String, int>.from(json.decode(goalsJson));
    }
    final startedList = _prefs!.getStringList('startedMatches');
    if (startedList != null) {
      _startedMatches = startedList.toSet();
    }
    
    final min15List = _prefs!.getStringList('15MinMatches');
    if (min15List != null) _15MinMatches = min15List.toSet();
    
    final halfTimeList = _prefs!.getStringList('halfTimeMatches');
    if (halfTimeList != null) _halfTimeMatches = halfTimeList.toSet();
    
    final finishedList = _prefs!.getStringList('finishedMatches');
    if (finishedList != null) _finishedMatches = finishedList.toSet();

    _mutedMatches = _prefs!.getStringList('muted_matches') ?? [];
    
    // Keep provider alive in this isolate
    _container!.listen(allMatchesProvider, (_, __) {});
    
    // Poll every 20 seconds
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _checkLiveUpdates();
    });
    
    int lastKnownFetchTime = 0;
    
    // Global 1-second ticker for LiveBadge sync and Widget update
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_container == null) return;
      
      // If foreground isolate, check if background isolate fetched new data
      if (!_updateWidget && _prefs != null) {
        await _prefs!.reload();
        final fetchTime = _prefs!.getInt('last_espn_fetch_time') ?? 0;
        if (fetchTime > lastKnownFetchTime && lastKnownFetchTime != 0) {
          lastKnownFetchTime = fetchTime;
          // Background isolate fetched new data (e.g. goal), instantly load it from cache to update UI!
          await _container!.read(allMatchesProvider.notifier).loadFromCache();
          // Re-sync local _matchGoals so we don't trigger a duplicate foreground notification
          final goalsJson = _prefs!.getString('matchGoals');
          if (goalsJson != null) {
            _matchGoals = Map<String, int>.from(json.decode(goalsJson));
          }
        } else if (lastKnownFetchTime == 0) {
          lastKnownFetchTime = fetchTime;
        }
      }

      for (var matchId in _liveMatchIds) {
        final current = _container!.read(matchClockProvider(matchId));
        final next = current + 1;
        _container!.read(matchClockProvider(matchId).notifier).state = next;
        
        if (_prefs != null && _updateWidget) {
          _prefs!.setInt('clock_$matchId', next);
          _prefs!.setInt('ts_$matchId', DateTime.now().millisecondsSinceEpoch);
        }
      }
      
      // Update widget clock every second
      if (_liveMatchIds.isNotEmpty) {
        _updateLiveWidgetClock();
      }
    });
    
    // Initial check
    _checkLiveUpdates();
  }

  Future<void> _updateLiveWidgetClock() async {
    if (_container == null || _liveMatchIds.isEmpty) return;
    try {
      final matchesAsync = _container!.read(allMatchesProvider);
      if (!matchesAsync.hasValue) return;
      final matches = matchesAsync.value!;
      final heroMatch = matches.firstWhere((m) => m.status == MatchStatus.live);
      final currentSeconds = _container!.read(matchClockProvider(heroMatch.id));
      
      String timeStr = heroMatch.displayClock ?? '';
      if (heroMatch.isHalftime) timeStr = 'DESCANSO';
      else if (currentSeconds > 0) {
        final mins = currentSeconds ~/ 60;
        final secs = currentSeconds % 60;
        timeStr = "$mins:${secs.toString().padLeft(2, '0')}";
      }

      if (_updateWidget) {
        await HomeWidget.saveWidgetData('widget_time', timeStr);
        await HomeWidget.updateWidget(androidName: 'LiveMatchWidgetProvider');
      }
    } catch (e) {
      // Ignorar si falla
    }
  }

  Future<void> _saveState() async {
    if (_prefs == null) return;
    await _prefs!.setString('matchGoals', json.encode(_matchGoals));
    await _prefs!.setStringList('startedMatches', _startedMatches.toList());
    await _prefs!.setStringList('15MinMatches', _15MinMatches.toList());
    await _prefs!.setStringList('halfTimeMatches', _halfTimeMatches.toList());
    await _prefs!.setStringList('finishedMatches', _finishedMatches.toList());
  }

  void stop() {
    _timer?.cancel();
    _tickerTimer?.cancel();
  }

  Future<void> _checkLiveUpdates() async {
    if (_container == null) return;

    if (_prefs != null) {
      await _prefs!.reload(); // Sync with background isolate
    }
    
    // Refresh muted matches on every tick to catch background changes
    final prefs = await SharedPreferences.getInstance();
    _mutedMatches = prefs.getStringList('muted_matches') ?? [];

    // Invalidate the provider silently to fetch new data
    try {
      await _container!.read(allMatchesProvider.notifier).refresh();
      final matchesAsync = _container!.read(allMatchesProvider);
      if (!matchesAsync.hasValue) return;
      final matches = matchesAsync.value!;
      bool hasLiveMatches = false;
      _liveMatchIds.clear();

      // Notification Preferences
      final matchStart15MinPref = prefs.getBool('matchStart15Min') ?? false;
      final matchStartedPref = prefs.getBool('matchStarted') ?? false;
      final goalPref = prefs.getBool('goal') ?? false;
      final halfTimePref = prefs.getBool('halfTime') ?? false;
      final finalResultPref = prefs.getBool('finalResult') ?? false;

      for (var match in matches) {
        if (match.status == MatchStatus.upcoming) {
          if (!_15MinMatches.contains(match.id)) {
            final now = DateTime.now();
            final diff = match.date.difference(now);
            if (diff.inMinutes <= 15 && diff.inMinutes >= 0 && !diff.isNegative) {
              _15MinMatches.add(match.id);
              _saveState();
              if (!_isFirstPoll && matchStart15MinPref && !_mutedMatches.contains(match.id)) {
                final notifKey = 'notified_15min_${match.id}';
                if (prefs.getBool(notifKey) != true) {
                  prefs.setBool(notifKey, true);
                  _sendNotification(
                    title: 'El partido está por comenzar',
                    body: '${match.homeTeam?.displayName ?? 'Local'} vs ${match.awayTeam?.displayName ?? 'Visitante'} inicia en menos de 15 minutos.',
                    matchId: match.id,
                  );
                }
              }
            }
          }
        } else if (match.status == MatchStatus.live) {
          hasLiveMatches = true;
          
          if (match.isTicking && match.clockSeconds != null) {
            _liveMatchIds.add(match.id);
            final current = _container!.read(matchClockProvider(match.id));
            int newSeconds = match.clockSeconds!.toInt();

            // Reconcile with persistence to calculate extra time if app was closed
            bool periodChanged = false;
            if (_prefs != null) {
              final savedPeriod = _prefs!.getInt('period_${match.id}');
              final savedClock = _prefs!.getInt('clock_${match.id}');
              final savedTs = _prefs!.getInt('ts_${match.id}');
              
              // Only apply extra time recovery if the period hasn't changed
              if (savedPeriod == null || savedPeriod == match.period) {
                if (savedClock != null && savedTs != null && savedClock >= newSeconds) {
                  final elapsed = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(savedTs)).inSeconds;
                  // Only trust elapsed if it's reasonable (e.g., less than 45 mins) to prevent massive jumps
                  if (elapsed > 0 && elapsed < 2700) {
                    newSeconds = savedClock + elapsed;
                  } else if (savedClock > newSeconds) {
                    newSeconds = savedClock;
                  }
                }
              } else {
                periodChanged = true; // Period changed (e.g., from 1 to 2), allow clock to reset to 45:00
              }
              // Save the current period so we know when it changes
              _prefs!.setInt('period_${match.id}', match.period);
            }

            if (newSeconds > current || current == 0 || periodChanged) {
              _container!.read(matchClockProvider(match.id).notifier).state = newSeconds;
            }
          }

          // Check for Match Started
          if (!_startedMatches.contains(match.id)) {
            _startedMatches.add(match.id);
            _15MinMatches.add(match.id); // Also mark 15min as done if it already started
            _saveState();
            if (!_isFirstPoll && matchStartedPref && !_mutedMatches.contains(match.id)) {
              final notifKey = 'notified_started_${match.id}';
              if (prefs.getBool(notifKey) != true) {
                prefs.setBool(notifKey, true);
                HapticFeedback.mediumImpact();
                
                String timeStr = '';
                if (match.clockSeconds != null && match.clockSeconds! > 60) {
                  final mins = match.clockSeconds! ~/ 60;
                  timeStr = ' (Minuto $mins\')';
                }
                
                _sendNotification(
                  title: '¡Partido Iniciado!', 
                  body: '${match.homeTeam?.displayName ?? 'Local'} vs ${match.awayTeam?.displayName ?? 'Visitante'} está en juego$timeStr.',
                  matchId: match.id,
                );
              }
            }
          }

          // Check for Halftime
          if (match.isHalftime && !_halfTimeMatches.contains(match.id)) {
            _halfTimeMatches.add(match.id);
            _saveState();
            if (!_isFirstPoll && halfTimePref && !_mutedMatches.contains(match.id)) {
              final notifKey = 'notified_halftime_${match.id}';
              if (prefs.getBool(notifKey) != true) {
                prefs.setBool(notifKey, true);
                _sendNotification(
                  title: '¡Medio Tiempo!', 
                  body: '${match.homeTeam?.displayName ?? 'Local'} ${match.homeTeam?.score} - ${match.awayTeam?.score} ${match.awayTeam?.displayName ?? 'Visitante'}',
                  matchId: match.id,
                );
              }
            }
          }

          // Check for Goals
          final currentGoals = match.goals.length;
          final previousGoals = _matchGoals[match.id] ?? currentGoals; // If it's the first time we see it, don't spam past goals
          
          if (currentGoals > previousGoals) {
            // New goal detected!
            final newGoal = match.goals.last;
            final teamName = newGoal.teamId == match.homeTeam?.id ? match.homeTeam?.displayName : match.awayTeam?.displayName;
            _matchGoals[match.id] = currentGoals;
            _saveState();
            if (!_isFirstPoll && !_mutedMatches.contains(match.id)) {
              // Trigger Lottie overlay if app is in foreground
              try {
                _container!.read(goalCelebrationProvider.notifier).state = true;
                HapticFeedback.heavyImpact();
                Future.delayed(const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
                Future.delayed(const Duration(milliseconds: 600), () => HapticFeedback.heavyImpact());
              } catch (e) {
                // ignore if container is disposed
              }
              
              if (goalPref) {
                final notifKey = 'notified_goal_${match.id}_${currentGoals}';
                if (prefs.getBool(notifKey) != true) {
                  prefs.setBool(notifKey, true);
                  _sendNotification(
                    title: '¡GOL de $teamName!', 
                    body: '${newGoal.playerName} anotó en el minuto ${newGoal.minute}. Marcador: ${match.homeTeam?.score} - ${match.awayTeam?.score}',
                    matchId: match.id,
                  );
                }
              }
            }
          } else {
            _matchGoals[match.id] = currentGoals;
            // No need to save state if goals haven't changed, but just to be safe if it's the first time
            if (previousGoals != currentGoals) _saveState();
          }
        } else if (match.status == MatchStatus.finished) {
          if (!_finishedMatches.contains(match.id)) {
            _finishedMatches.add(match.id);
            _startedMatches.add(match.id);
            _halfTimeMatches.add(match.id);
            _saveState();
            
            // Only notify if it finished recently (e.g., today) and not on first poll
            final now = DateTime.now();
            final isRecent = now.difference(match.date).inDays < 2;

            if (!_isFirstPoll && isRecent && finalResultPref && !_mutedMatches.contains(match.id)) {
              final notifKey = 'notified_finished_${match.id}';
              if (prefs.getBool(notifKey) != true) {
                prefs.setBool(notifKey, true);
                _sendNotification(
                  title: '¡Partido Finalizado!', 
                  body: '${match.homeTeam?.displayName ?? 'Local'} ${match.homeTeam?.score} - ${match.awayTeam?.score} ${match.awayTeam?.displayName ?? 'Visitante'}',
                  matchId: match.id,
                );
              }
            }
          }

          if (_matchGoals.containsKey(match.id)) {
            _matchGoals.remove(match.id);
            _saveState();
          }
        }
      }
      
      if (hasLiveMatches) {
        _container!.invalidate(groupsProvider);
      }

      _isFirstPoll = false;

      // Update Home Screen Widget with the most prominent live match
      if (_updateWidget) {
        if (hasLiveMatches) {
          final heroMatch = matches.firstWhere((m) => m.status == MatchStatus.live);
          
          await HomeWidget.saveWidgetData('widget_title', 'EN VIVO - MUNDIAL 26');
          await HomeWidget.saveWidgetData('widget_home_team', heroMatch.homeTeam?.displayName ?? 'Local');
          await HomeWidget.saveWidgetData('widget_away_team', heroMatch.awayTeam?.displayName ?? 'Visitante');
          await HomeWidget.saveWidgetData('widget_score', '${heroMatch.homeTeam?.score ?? 0} - ${heroMatch.awayTeam?.score ?? 0}');
          await HomeWidget.saveWidgetData('widget_home_logo', heroMatch.homeTeam?.logoUrl ?? '');
          await HomeWidget.saveWidgetData('widget_away_logo', heroMatch.awayTeam?.logoUrl ?? '');
          
          final homeGoalsStr = heroMatch.goals.where((g) => g.teamId == heroMatch.homeTeam?.id).map((g) => '${g.playerName} ${g.minute}\'').join('\n');
          final awayGoalsStr = heroMatch.goals.where((g) => g.teamId == heroMatch.awayTeam?.id).map((g) => '${g.playerName} ${g.minute}\'').join('\n');
          await HomeWidget.saveWidgetData('widget_home_scorers', homeGoalsStr);
          await HomeWidget.saveWidgetData('widget_away_scorers', awayGoalsStr);

          _updateLiveWidgetClock();
        } else {
          // Find next upcoming match
          final upcomingMatches = matches.where((m) => m.status == MatchStatus.upcoming).toList();
          if (upcomingMatches.isNotEmpty) {
            upcomingMatches.sort((a, b) => a.date.compareTo(b.date));
            final nextMatch = upcomingMatches.first;
            
            final dateStr = '${AppDateUtils.formatShortDay(nextMatch.date)} ${AppDateUtils.formatTime(nextMatch.date)}';
            
            await HomeWidget.saveWidgetData('widget_title', 'PRÓXIMO PARTIDO');
            await HomeWidget.saveWidgetData('widget_time', dateStr);
            await HomeWidget.saveWidgetData('widget_home_team', nextMatch.homeTeam?.displayName ?? 'Local');
            await HomeWidget.saveWidgetData('widget_away_team', nextMatch.awayTeam?.displayName ?? 'Visitante');
            await HomeWidget.saveWidgetData('widget_score', 'vs');
            await HomeWidget.saveWidgetData('widget_home_logo', nextMatch.homeTeam?.logoUrl ?? '');
            await HomeWidget.saveWidgetData('widget_away_logo', nextMatch.awayTeam?.logoUrl ?? '');
            await HomeWidget.saveWidgetData('widget_home_scorers', '');
            await HomeWidget.saveWidgetData('widget_away_scorers', '');
            await HomeWidget.updateWidget(androidName: 'LiveMatchWidgetProvider');
          } else {
            // Clear widget if no live matches and no upcoming
            await HomeWidget.saveWidgetData('widget_title', 'Mundial 2026');
            await HomeWidget.saveWidgetData('widget_time', 'Sin partidos en vivo');
            await HomeWidget.saveWidgetData('widget_home_team', '--');
            await HomeWidget.saveWidgetData('widget_away_team', '--');
            await HomeWidget.saveWidgetData('widget_score', '-');
            await HomeWidget.saveWidgetData('widget_home_logo', '');
            await HomeWidget.saveWidgetData('widget_away_logo', '');
            await HomeWidget.saveWidgetData('widget_home_scorers', '');
            await HomeWidget.saveWidgetData('widget_away_scorers', '');
            await HomeWidget.updateWidget(androidName: 'LiveMatchWidgetProvider');
          }
        }
      }

      // Automatically refresh groups if there's a live match
      if (hasLiveMatches) {
        _container!.invalidate(groupsProvider);
      }
    } catch (e) {
      // Failed to poll
    }
  }

  void _sendNotification({required String title, required String body, String? matchId}) {
    if (_sendNotifications) {
      NotificationService().showMatchNotification(title: title, body: body, matchId: matchId);
    }
  }
}
