class Article {
  final String id;
  final String title;
  final String category; // Basics, Nutrition, Hygiene, Health, Behavior
  final String content;
  final int readTimeMinutes;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.readTimeMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'read_time_minutes': readTimeMinutes,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      content: map['content'] as String,
      readTimeMinutes: (map['read_time_minutes'] as num?)?.toInt() ?? 3,
    );
  }
}
