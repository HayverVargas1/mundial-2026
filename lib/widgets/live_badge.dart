import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';

class LiveBadge extends ConsumerWidget {
  final String matchId;
  final String? clock;
  final double? clockSeconds;
  final int period;
  final bool isTicking;
  final bool isHalftime;
  final bool compact;

  const LiveBadge({
    Key? key,
    required this.matchId,
    this.clock,
    this.clockSeconds,
    this.period = 1,
    this.isTicking = false,
    this.isHalftime = false,
    this.compact = false,
  }) : super(key: key);

  String _getDisplayTime(int currentSeconds) {
    if (isHalftime) {
      return 'DESCANSO';
    }
    if (!isTicking) {
      return clock ?? 'EN ESPERA';
    }

    if (clockSeconds != null) {
      final int minutes = currentSeconds ~/ 60;
      final int seconds = currentSeconds % 60;

      // Handle stoppage time
      if (period == 1 && minutes >= 45) {
        final addedSeconds = currentSeconds - 2700; // 45 * 60
        final addedMins = addedSeconds ~/ 60;
        final addedSecs = addedSeconds % 60;
        return '45:00 +$addedMins:${addedSecs.toString().padLeft(2, '0')}';
      } else if (period == 2 && minutes >= 90) {
        final addedSeconds = currentSeconds - 5400; // 90 * 60
        final addedMins = addedSeconds ~/ 60;
        final addedSecs = addedSeconds % 60;
        return '90:00 +$addedMins:${addedSecs.toString().padLeft(2, '0')}';
      }

      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return clock ?? '';
  }


  Widget _buildTimeWidget(String timeStr, bool compact) {
    if (timeStr.isEmpty) return const SizedBox();

    if (timeStr.contains('+')) {
      final parts = timeStr.split('+');
      final base = parts[0].trim();
      final extra = '+${parts[1].trim()}';
      
      final children = [
        Text(
          base,
          style: TextStyle(
            color: Colors.white,
            fontWeight: compact ? FontWeight.bold : FontWeight.w900,
            fontSize: compact ? 11 : 18,
            letterSpacing: compact ? 0.5 : 1.0,
            shadows: compact ? null : const [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        if (compact) const SizedBox(width: 4),
        Text(
          extra,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: compact ? 10 : 14,
            letterSpacing: compact ? 0.5 : 1.0,
            shadows: compact ? null : const [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
      ];

      if (compact) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: children,
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        );
      }
    }

    return Text(
      timeStr,
      style: TextStyle(
        color: Colors.white,
        fontWeight: compact ? FontWeight.bold : FontWeight.w900,
        fontSize: compact ? 11 : 18,
        letterSpacing: compact ? 0.5 : 1.0,
        shadows: compact ? null : const [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentSeconds = ref.watch(matchClockProvider(matchId));
    if (currentSeconds == 0 && clockSeconds != null) {
      currentSeconds = clockSeconds!.toInt();
    }
    final timeStr = _getDisplayTime(currentSeconds);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.redAccent, blurRadius: 4, spreadRadius: 0.5)
                ],
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeOut(duration: 800.ms),
            const SizedBox(width: 6),
            Text(
              'EN VIVO',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
            if (timeStr.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 1,
                height: 12,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildTimeWidget(timeStr, true),
            ],
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent, blurRadius: 8, spreadRadius: 1)
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeOut(duration: 800.ms),
              const SizedBox(width: 8),
              Text(
                'EN VIVO',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (timeStr.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildTimeWidget(timeStr, false),
          ),
      ],
    );
  }
}
