import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../models/match_model.dart';
import '../models/group_model.dart';
import '../models/match_summary_model.dart';
import '../core/constants/espn_constants.dart';
import '../core/utils/date_utils.dart';
import '../services/espn_service.dart';
import '../services/matches_service.dart';
import '../services/standings_service.dart';
import '../repositories/matches_repository.dart';
import '../repositories/standings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Persisted Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider is not initialized');
});

// Services
final espnServiceProvider = Provider((ref) => EspnService());

final matchesServiceProvider = Provider((ref) {
  final api = ref.watch(espnServiceProvider);
  return MatchesService(api);
});

final standingsServiceProvider = Provider((ref) {
  final api = ref.watch(espnServiceProvider);
  return StandingsService(api);
});

// Repositories
final matchesRepositoryProvider = Provider((ref) {
  return MatchesRepository(ref.watch(matchesServiceProvider));
});

final standingsRepositoryProvider = Provider((ref) {
  return StandingsRepository(ref.watch(standingsServiceProvider));
});

// State Providers
final selectedDateProvider =
    StateProvider<DateTime>((ref) => AppDateUtils.nowColombia());

final matchClockProvider = StateProvider.family<int, String>((ref, matchId) => 0);

final allMatchesProvider = StateNotifierProvider.autoDispose<AllMatchesNotifier, AsyncValue<List<MatchModel>>>((ref) {
  return AllMatchesNotifier(ref.watch(matchesServiceProvider));
});

class AllMatchesNotifier extends StateNotifier<AsyncValue<List<MatchModel>>> {
  final MatchesService _service;

  AllMatchesNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await loadFromCache();
    refresh();
  }

  Future<void> loadFromCache() async {
    final cached = await _service.getCachedMatches();
    if (cached != null && mounted) {
      state = AsyncValue.data(cached);
    }
  }

  Future<void> refresh() async {
    try {
      final matches = await _service.getMatches('20260611-20260719');
      if (mounted) state = AsyncValue.data(matches);
    } catch (e, st) {
      if (mounted && !state.hasValue) {
        state = AsyncValue.error(e, st);
      }
    }
  }


}

final matchesProvider =
    Provider.autoDispose<AsyncValue<List<MatchModel>>>((ref) {
  final globalAsync = ref.watch(allMatchesProvider);
  final date = ref.watch(selectedDateProvider);

  return globalAsync.whenData((allMatches) {
    return allMatches
        .where((m) => AppDateUtils.isMatchOnSelectedDate(m.date, date))
        .toList();
  });
});

final heroMatchProvider = Provider.autoDispose<AsyncValue<MatchModel?>>((ref) {
  final globalAsync = ref.watch(allMatchesProvider);
  
  if (globalAsync.hasValue) {
    final allMatches = globalAsync.value!;
    if (allMatches.isEmpty) return const AsyncValue.data(null);

    final liveMatches =
        allMatches.where((m) => m.status == MatchStatus.live).toList();
    if (liveMatches.isNotEmpty) return AsyncValue.data(liveMatches.first);

    final upcomingMatches =
        allMatches.where((m) => m.status == MatchStatus.upcoming).toList();
    if (upcomingMatches.isNotEmpty) {
      upcomingMatches.sort((a, b) => a.date.compareTo(b.date));
      return AsyncValue.data(upcomingMatches.first);
    }

    final finishedMatches =
        allMatches.where((m) => m.status == MatchStatus.finished).toList();
    finishedMatches.sort((a, b) => b.date.compareTo(a.date));
    return AsyncValue.data(finishedMatches.isNotEmpty
        ? finishedMatches.first
        : allMatches.first);
  }
  
  return const AsyncValue.loading();
});

final groupsProvider =
    FutureProvider.autoDispose<List<GroupModel>>((ref) async {
  final repo = ref.watch(standingsRepositoryProvider);
  return repo.getGroups();
});

final matchDetailsProvider = FutureProvider.family
    .autoDispose<MatchSummaryModel, String>((ref, eventId) async {
  final service = ref.watch(espnServiceProvider);
  final data = await service.get(EspnConstants.summaryUrl(eventId));
  return MatchSummaryModel.fromJson(data);
});

final goalCelebrationProvider = StateProvider<bool>((ref) => false);
