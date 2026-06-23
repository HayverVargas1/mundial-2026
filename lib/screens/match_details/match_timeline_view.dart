import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match_model.dart';
import '../../providers/app_providers.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/event_icon_helper.dart';

class MatchTimelineView extends ConsumerStatefulWidget {
  final MatchModel match;

  const MatchTimelineView({Key? key, required this.match, dynamic summary}) : super(key: key);

  @override
  ConsumerState<MatchTimelineView> createState() => _MatchTimelineViewState();
}

class _MatchTimelineViewState extends ConsumerState<MatchTimelineView> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.match.status == MatchStatus.live) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        ref.invalidate(matchDetailsProvider(widget.match.id));
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(matchDetailsProvider(widget.match.id));

    return summaryAsync.when(
      data: (summary) {
        if (summary.commentaries.isEmpty) {
          return const Center(
            child: Text(
              'No hay comentarios disponibles',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        // Most recent first
        final items = summary.commentaries.reversed.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final c = items[index];
            final isNewest = index == 0 && widget.match.status == MatchStatus.live;
            final isKeyEvent = c.eventType == 'goal' || c.eventType == 'redCard';

            final bgColor = isNewest
                ? AppColors.live.withOpacity(0.07)
                : isKeyEvent
                    ? eventTypeColor(c.eventType)
                    : Colors.transparent;

            final borderColor = isNewest
                ? AppColors.live.withOpacity(0.3)
                : isKeyEvent
                    ? eventTypeBorderColor(c.eventType)
                    : AppColors.border.withOpacity(0.4);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time + live dot
                  SizedBox(
                    width: 46,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isNewest)
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(bottom: 3),
                            decoration: const BoxDecoration(color: AppColors.live, shape: BoxShape.circle),
                          ),
                        Text(
                          c.time.isNotEmpty ? c.time : '—',
                          style: TextStyle(
                            color: isNewest ? AppColors.live : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Timeline line
                  Container(
                    width: 2,
                    height: isKeyEvent ? 52 : 40,
                    color: isNewest
                        ? AppColors.live.withOpacity(0.4)
                        : isKeyEvent
                            ? eventTypeBorderColor(c.eventType)
                            : AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  // Comment bubble
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: bgColor == Colors.transparent ? AppColors.surface : bgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event icon
                          Padding(
                            padding: const EdgeInsets.only(right: 8, top: 1),
                            child: buildEventIcon(c.eventType, size: 16),
                          ),
                          // Text
                          Expanded(
                            child: Text(
                              c.text,
                              style: TextStyle(
                                color: isNewest ? Colors.white : Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: isKeyEvent ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => const Center(
        child: Text('Error cargando comentarios', style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }
}
