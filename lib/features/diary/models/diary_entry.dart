import 'dart:convert';

class DiaryEntry {
  final String id;
  final String birdId;
  final String date; // YYYY-MM-DD
  final String title;
  final String content;
  final List<String> photoPaths;
  final String createdAt;

  DiaryEntry({
    required this.id,
    required this.birdId,
    required this.date,
    required this.title,
    required this.content,
    this.photoPaths = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bird_id': birdId,
      'date': date,
      'title': title,
      'content': content,
      'photo_paths': jsonEncode(photoPaths),
      'created_at': createdAt,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    List<String> photos = [];
    if (map['photo_paths'] != null && (map['photo_paths'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(map['photo_paths'] as String);
        if (decoded is List) {
          photos = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return DiaryEntry(
      id: map['id'] as String,
      birdId: map['bird_id'] as String,
      date: map['date'] as String,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      photoPaths: photos,
      createdAt: map['created_at'] as String,
    );
  }
}
