import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/commentary_model.dart';

/// Returns the appropriate icon widget for a commentary event type.
Widget buildEventIcon(String eventType, {double size = 16}) {
  switch (eventType) {
    case 'goal':
      return Icon(Icons.sports_soccer, color: Colors.greenAccent, size: size);
    case 'yellowCard':
      return Container(
        width: size * 0.75,
        height: size,
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 4)],
        ),
      );
    case 'redCard':
      return Container(
        width: size * 0.75,
        height: size,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 4)],
        ),
      );
    case 'substitution':
      return Icon(Icons.swap_vert, color: Colors.greenAccent, size: size);
    case 'offside':
      return Icon(Icons.flag, color: Colors.orange, size: size);
    case 'corner':
      return Icon(Icons.flag_outlined, color: AppColors.primary, size: size);
    case 'foul':
      return Icon(Icons.warning_amber_rounded, color: Colors.orange, size: size);
    default:
      return Icon(Icons.circle, color: AppColors.textSecondary.withOpacity(0.4), size: size * 0.5);
  }
}

/// Returns event type color for background highlighting
Color eventTypeColor(String eventType) {
  switch (eventType) {
    case 'goal': return Colors.greenAccent.withOpacity(0.08);
    case 'yellowCard': return Colors.amber.withOpacity(0.08);
    case 'redCard': return Colors.red.withOpacity(0.08);
    case 'substitution': return Colors.green.withOpacity(0.06);
    default: return Colors.transparent;
  }
}

/// Returns border color for event type
Color eventTypeBorderColor(String eventType) {
  switch (eventType) {
    case 'goal': return Colors.greenAccent.withOpacity(0.3);
    case 'yellowCard': return Colors.amber.withOpacity(0.3);
    case 'redCard': return Colors.red.withOpacity(0.3);
    case 'substitution': return Colors.green.withOpacity(0.2);
    default: return AppColors.border.withOpacity(0.5);
  }
}

/// Inline single commentary row used in both HeroMatchCard and MatchTimelineView.
Widget buildCommentaryRow(CommentaryModel c, {bool compact = false}) {
  final hasIcon = c.eventType.isNotEmpty;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Time
      if (c.time.isNotEmpty)
        SizedBox(
          width: 36,
          child: Text(
            c.time,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      // Event icon
      SizedBox(
        width: 22,
        child: Center(child: buildEventIcon(c.eventType, size: compact ? 13 : 15)),
      ),
      const SizedBox(width: 6),
      // Text
      Expanded(
        child: Text(
          c.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 11 : 13,
            height: 1.3,
          ),
          maxLines: compact ? 2 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
        ),
      ),
    ],
  );
}
