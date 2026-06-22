import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match_model.dart';
import '../../providers/app_providers.dart';
import '../../core/constants/app_colors.dart';

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
    // Auto-refresh every 30s if match is live
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

        // Reverse: most recent first
        final items = summary.commentaries.reversed.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final c = items[index];
            final isFirst = index == 0 && widget.match.status == MatchStatus.live;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time column
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: [
                        if (isFirst)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: const BoxDecoration(
                              color: AppColors.live,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          c.time.isNotEmpty ? c.time : '—',
                          style: TextStyle(
                            color: isFirst ? AppColors.live : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Line
                  Container(
                    width: 2,
                    height: 40,
                    color: isFirst
                        ? AppColors.live.withOpacity(0.5)
                        : AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  // Comment bubble
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? AppColors.live.withOpacity(0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFirst
                              ? AppColors.live.withOpacity(0.3)
                              : AppColors.border.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        c.text,
                        style: TextStyle(
                          color: isFirst ? Colors.white : Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: isFirst ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          'Error cargando comentarios',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
