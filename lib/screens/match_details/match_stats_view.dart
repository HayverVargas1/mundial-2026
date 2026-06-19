import 'package:flutter/material.dart';
import '../../models/match_model.dart';
import '../../models/match_summary_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/team_flag.dart';

class MatchStatsView extends StatelessWidget {
  final MatchSummaryModel summary;
  final MatchModel match;

  const MatchStatsView({Key? key, required this.summary, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (summary.homeStats.isEmpty && summary.awayStats.isEmpty) {
      return const Center(child: Text('Estadísticas no disponibles aún', style: TextStyle(color: AppColors.textSecondary)));
    }

    // Combine stats by name
    final Set<String> statNames = {};
    for (var s in summary.homeStats) statNames.add(s.name);
    for (var s in summary.awayStats) statNames.add(s.name);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: statNames.map((statName) {
        final homeStat = summary.homeStats.firstWhere((s) => s.name == statName, orElse: () => TeamStat(name: statName, displayValue: '0', label: statName));
        final awayStat = summary.awayStats.firstWhere((s) => s.name == statName, orElse: () => TeamStat(name: statName, displayValue: '0', label: statName));

        double homeVal = double.tryParse(homeStat.displayValue.replaceAll('%', '')) ?? 0;
        double awayVal = double.tryParse(awayStat.displayValue.replaceAll('%', '')) ?? 0;
        double total = homeVal + awayVal;
        if (total == 0) total = 1;

        // Translate labels
        String translatedLabel = homeStat.label.toUpperCase();
        const Map<String, String> translations = {
          'POSSESSION': 'POSESIÓN',
          'FOULS': 'FALTAS',
          'YELLOW CARDS': 'TARJETAS AMARILLAS',
          'RED CARDS': 'TARJETAS ROJAS',
          'OFFSIDES': 'FUERAS DE JUEGO',
          'CORNER KICKS': 'TIROS DE ESQUINA',
          'SAVES': 'ATAJADAS',
          'SHOTS': 'TIROS TOTALES',
          'SHOTS ON TARGET': 'TIROS A PUERTA',
          'SHOTS ON GOAL': 'TIROS A PUERTA',
          'PASSES': 'PASES',
          'PASS ACCURACY': 'PRECISIÓN DE PASES',
          'ON GOAL': 'GOLES',
          'ON TARGET %': '% AL ARCO',
          'PENALTY GOALS': 'GOLES DE PENALTI',
          'PENALTY KICKS TAKEN': 'PENALTIS EJECUTADOS',
          'GOAL DIFFERENCE': 'DIFERENCIA DE GOLES',
          'TOTAL GOALS': 'GOLES TOTALES',
          'ASSISTS': 'ASISTENCIAS',
          'GOALS AGAINST': 'GOLES EN CONTRA',
          'PASSING ACCURACY': 'PRECISIÓN DE PASES',
          'PASS COMPLETION %': '% DE PASES COMPLETADOS',
          'ACCURATE PASSES': 'PASES PRECISOS',
          'ACCURATE CROSSES': 'CENTROS PRECISOS',
          'CROSSES': 'CENTROS',
          'CROSS %': 'PORCENTAJE DE CENTROS',
          'LONG BALLS': 'PASES LARGOS',
          'LONG BALLS %': '% DE PASES LARGOS',
          'ACCURATE LONG BALLS': '% DE PASES LARGOS',
          'BLOCKED SHOTS': 'TIROS BLOQUEADOS',
          'EFFECTIVE TACKLES': 'DEFENSA EFECTIVA',
          'TACKLES': 'ENTRADAS',
          'TACKLE %': '% DE ENTRADAS',
          'INTERCEPTIONS': 'INTERCEPCIONES',
          'EFFECTIVE CLEARANCES': 'DESPEJES EFECTIVOS',
          'CLEARANCES': 'DESPEJES',
        };
        
        if (translations.containsKey(translatedLabel)) {
          translatedLabel = translations[translatedLabel]!;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(homeStat.displayValue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(translatedLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(awayStat.displayValue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: (homeVal * 100).toInt(),
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: (awayVal * 100).toInt(),
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.live,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
