import 'package:flutter/material.dart';
import '../models/group_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import 'team_flag.dart';

class GroupTable extends StatelessWidget {
  final GroupModel group;
  final Set<String> topThirdPlacesIds;
  final bool showHeader;
  final EdgeInsetsGeometry? margin;

  const GroupTable({
    Key? key,
    required this.group,
    this.topThirdPlacesIds = const {},
    this.showHeader = false,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                    bottom:
                        BorderSide(color: AppColors.border.withOpacity(0.5))),
              ),
              child: Text(
                group.name
                    .toUpperCase()
                    .replaceAll('GROUP', 'GRUPO')
                    .replaceAll('GROUP', 'GRUPO'),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FixedColumnWidth(24),
                1: FlexColumnWidth(1),
                2: FixedColumnWidth(22),
                3: FixedColumnWidth(20),
                4: FixedColumnWidth(20),
                5: FixedColumnWidth(20),
                6: FixedColumnWidth(20),
                7: FixedColumnWidth(20),
                8: FixedColumnWidth(24),
                9: FixedColumnWidth(26),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.border.withOpacity(0.3))),
                  ),
                  children: [
                    _buildHeaderCell('POS'),
                    _buildHeaderCell('EQUIPO', alignment: Alignment.centerLeft),
                    _buildHeaderCell('PJ'),
                    _buildHeaderCell('G'),
                    _buildHeaderCell('E'),
                    _buildHeaderCell('P'),
                    _buildHeaderCell('GF'),
                    _buildHeaderCell('GC'),
                    _buildHeaderCell('DG'),
                    _buildHeaderCell('PTS', highlight: true),
                  ],
                ),
                ...group.standings.asMap().entries.map((entry) {
                  final index = entry.key;
                  final standing = entry.value;
                  final team = standing.team;

                  Color? rowColor;
                  if (index < 2) {
                    rowColor = const Color.fromARGB(255, 79, 223, 66)
                        .withOpacity(0.20);
                  } else if (index == 2 &&
                      topThirdPlacesIds.contains(team.id)) {
                    rowColor = const Color.fromARGB(255, 218, 221, 60)
                        .withOpacity(0.20);
                  }

                  return TableRow(
                    decoration: BoxDecoration(
                      color: rowColor,
                      border: Border(
                          bottom: BorderSide(
                              color: const Color.fromARGB(255, 253, 253, 255)
                                  .withOpacity(0.2))),
                    ),
                    children: [
                      _buildCell('${index + 1}', isBold: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            TeamFlag(
                                logoUrl: team.logoUrl,
                                teamName: team.displayName,
                                size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                team.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildCell('${standing.matchesPlayed}'),
                      _buildCell('${standing.matchesWon}'),
                      _buildCell('${standing.matchesDrawn}'),
                      _buildCell('${standing.matchesLost}'),
                      _buildCell('${standing.goalsFor}'),
                      _buildCell('${standing.goalsAgainst}'),
                      _buildCell('${standing.goalDifference}'),
                      _buildCell('${standing.points}',
                          isBold: true, fontSize: 13),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text,
      {Alignment alignment = Alignment.center, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: alignment,
        child: Text(
          text,
          style: TextStyle(
            color: highlight ? Colors.white : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildCell(String text,
      {bool isBold = false,
      double fontSize = 11,
      Alignment alignment = Alignment.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: alignment,
        child: Text(
          text,
          style: TextStyle(
            color: isBold ? Colors.white : AppColors.textSecondary,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
        ),
      ),
    );
  }
}
