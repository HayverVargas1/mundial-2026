class CommentaryModel {
  final String text;
  final String time;
  final String eventType; // 'goal', 'yellowCard', 'redCard', 'substitution', 'offside', ''

  CommentaryModel({
    required this.text,
    required this.time,
    this.eventType = '',
  });

  factory CommentaryModel.fromJson(Map<String, dynamic> json) {
    String timeStr = '';
    if (json['time'] != null && json['time']['displayValue'] != null) {
      timeStr = json['time']['displayValue'];
    }

    // Parse event type from API
    String eventType = '';
    if (json['type'] != null) {
      eventType = (json['type']['id'] ?? json['type']['text'] ?? '').toString().toLowerCase();
    }

    final text = (json['text'] ?? '').toString();

    // Fallback: detect from text keywords
    if (eventType.isEmpty) {
      final lower = text.toLowerCase();
      if (lower.contains('gol') || lower.contains('goal') || lower.contains('anota')) {
        eventType = 'goal';
      } else if (lower.contains('tarjeta amarilla') || lower.contains('yellow card') || lower.contains('amonestado')) {
        eventType = 'yellowCard';
      } else if (lower.contains('tarjeta roja') || lower.contains('red card') || lower.contains('expulsado')) {
        eventType = 'redCard';
      } else if (lower.contains('cambio') || lower.contains('sustituc') || lower.contains('substitution') || lower.contains('reemplaz')) {
        eventType = 'substitution';
      } else if (lower.contains('fuera de juego') || lower.contains('offside')) {
        eventType = 'offside';
      } else if (lower.contains('tiro de esquina') || lower.contains('corner')) {
        eventType = 'corner';
      } else if (lower.contains('falta') || lower.contains('foul')) {
        eventType = 'foul';
      }
    } else {
      // Normalize API event type strings
      if (eventType.contains('goal') || eventType.contains('scoring')) {
        eventType = 'goal';
      } else if (eventType.contains('yellow')) {
        eventType = 'yellowCard';
      } else if (eventType.contains('red')) {
        eventType = 'redCard';
      } else if (eventType.contains('sub')) {
        eventType = 'substitution';
      } else if (eventType.contains('offside')) {
        eventType = 'offside';
      } else if (eventType.contains('corner')) {
        eventType = 'corner';
      }
    }

    return CommentaryModel(
      text: text,
      time: timeStr,
      eventType: eventType,
    );
  }
}
