import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/team_model.dart';
import '../../providers/teams_provider.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/team_flag.dart';
import '../../core/constants/app_colors.dart';

class TeamDetailsScreen extends ConsumerWidget {
  final TeamModel team;

  const TeamDetailsScreen({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosterAsync = ref.watch(rosterProvider(team.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(team.displayName),
        backgroundColor: AppColors.surface,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  TeamFlag(logoUrl: team.logoUrl, teamName: team.displayName, size: 100),
                  const SizedBox(height: 16),
                  Text(
                    team.displayName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (team.abbreviation.isNotEmpty)
                    Text(
                      team.abbreviation,
                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ),
          
          rosterAsync.when(
            data: (roster) {
              final positionTranslations = {
                'Forward': 'Delantero',
                'Midfielder': 'Mediocampista',
                'Defender': 'Defensa',
                'Goalkeeper': 'Portero',
              };

              final groupedPlayers = <String, List>{};
              for (var player in roster.athletes) {
                final pos = positionTranslations[player.positionName] ?? player.positionName;
                if (!groupedPlayers.containsKey(pos)) {
                  groupedPlayers[pos] = [];
                }
                groupedPlayers[pos]!.add(player);
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  if (roster.coaches.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Entrenador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    ...roster.coaches.map((coach) => ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.secondary,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text('${coach.firstName} ${coach.lastName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Coach'),
                        )),
                    const Divider(color: AppColors.border),
                  ],
                  
                  ...groupedPlayers.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        ...entry.value.map((player) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.surface,
                                child: Text(
                                  player.jersey ?? '-',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(player.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: player.age != null ? Text('${player.age} años') : null,
                              trailing: Text(player.positionAbbrev, style: const TextStyle(color: AppColors.textSecondary)),
                            )),
                        const Divider(color: AppColors.border),
                      ],
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                ]),
              );
            },
            loading: () => const SliverToBoxAdapter(child: LoadingSkeleton()),
            error: (err, stack) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No se pudo cargar la plantilla')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
