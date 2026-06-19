import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match_model.dart';
import '../../models/group_model.dart';
import '../../providers/app_providers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/group_table.dart';
import '../../widgets/match_card.dart';
import '../../widgets/team_flag.dart';

class TeamMatchesTab extends ConsumerStatefulWidget {
  final MatchModel match;

  const TeamMatchesTab({Key? key, required this.match}) : super(key: key);

  @override
  ConsumerState<TeamMatchesTab> createState() => _TeamMatchesTabState();
}

class _TeamMatchesTabState extends ConsumerState<TeamMatchesTab> {
  late bool _isHomeSelected;

  @override
  void initState() {
    super.initState();
    _isHomeSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeam = _isHomeSelected ? widget.match.homeTeam : widget.match.awayTeam;
    
    return Column(
      children: [
        const SizedBox(height: 16),
        // Team Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isHomeSelected = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isHomeSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.match.homeTeam?.displayName ?? 'Local',
                        style: TextStyle(
                          color: _isHomeSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: _isHomeSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.border),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isHomeSelected = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isHomeSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.match.awayTeam?.displayName ?? 'Visitante',
                        style: TextStyle(
                          color: !_isHomeSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: !_isHomeSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: selectedTeam == null 
              ? const Center(child: Text('Equipo no disponible'))
              : _TeamDetailsView(teamId: selectedTeam.id, currentMatchId: widget.match.id),
        ),
      ],
    );
  }
}

class _TeamDetailsView extends ConsumerWidget {
  final String teamId;
  final String currentMatchId;

  const _TeamDetailsView({Key? key, required this.teamId, required this.currentMatchId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMatchesAsync = ref.watch(allMatchesProvider);
    final groupsAsync = ref.watch(groupsProvider);

    return CustomScrollView(
      slivers: [
        // Group Standing
        groupsAsync.when(
          data: (groups) {
            GroupModel? teamGroup;
            int position = -1;
            for (var group in groups) {
              final index = group.standings.indexWhere((s) => s.team.id == teamId);
              if (index != -1) {
                teamGroup = group;
                position = index + 1;
                break;
              }
            }
            if (teamGroup == null) return const SliverToBoxAdapter(child: SizedBox());
            
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.textSecondary,
                    title: Row(
                      children: [
                        Text(
                          teamGroup.name.replaceAll('Group', 'Grupo').replaceAll('group', 'Grupo'), 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.border,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GroupTable(group: teamGroup, margin: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
        ),

        // Team Matches
        allMatchesAsync.when(
          data: (matches) {
            final teamMatches = matches.where((m) => m.homeTeam?.id == teamId || m.awayTeam?.id == teamId).toList();
            teamMatches.sort((a, b) => a.date.compareTo(b.date));
            final upcomingMatches = teamMatches.where((m) => m.status == MatchStatus.upcoming).toList();
            final pastMatches = teamMatches.where((m) => m.status != MatchStatus.upcoming).toList();
            // pastMatches should be most recent first usually, but lets keep chronological
            
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (upcomingMatches.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text('Próximos partidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    ),
                    ...upcomingMatches.map((m) => MatchCard(match: m, showDate: true, isClickable: m.id != currentMatchId)).toList(),
                  ],
                  if (pastMatches.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
                      child: Text('Partidos Ya jugados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    ),
                    ...pastMatches.map((m) => MatchCard(match: m, showDate: true, isClickable: m.id != currentMatchId)).toList(),
                  ],
                ],
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
