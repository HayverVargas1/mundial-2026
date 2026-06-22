class CommentaryModel {
  final String text;
  final String time;

  CommentaryModel({
    required this.text,
    required this.time,
  });

  factory CommentaryModel.fromJson(Map<String, dynamic> json) {
    String timeStr = '';
    if (json['time'] != null && json['time']['displayValue'] != null) {
      timeStr = json['time']['displayValue'];
    }

    return CommentaryModel(
      text: json['text'] ?? '',
      time: timeStr,
    );
  }
}
