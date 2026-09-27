class CareReminder {
  final String id;
  final String? birdId;
  final String title;
  final String time; // HH:mm format
  final List<int> repeatDays; // 1 = Monday ... 7 = Sunday
  final bool isEnabled;
  final String category; // Feed, Water, Clean, Bath, Custom

  CareReminder({
    required this.id,
    this.birdId,
    required this.title,
    required this.time,
    this.repeatDays = const [1, 2, 3, 4, 5, 6, 7],
    this.isEnabled = true,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bird_id': birdId,
      'title': title,
      'time': time,
      'repeat_days': repeatDays.join(','),
      'is_enabled': isEnabled ? 1 : 0,
      'category': category,
    };
  }

  factory CareReminder.fromMap(Map<String, dynamic> map) {
    List<int> days = [1, 2, 3, 4, 5, 6, 7];
    if (map['repeat_days'] != null && (map['repeat_days'] as String).isNotEmpty) {
      days = (map['repeat_days'] as String)
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 1)
          .toList();
    }

    return CareReminder(
      id: map['id'] as String,
      birdId: map['bird_id'] as String?,
      title: map['title'] as String,
      time: map['time'] as String,
      repeatDays: days,
      isEnabled: (map['is_enabled'] as int?) == 1,
      category: (map['category'] as String?) ?? 'Custom',
    );
  }

  CareReminder copyWith({
    String? id,
    String? birdId,
    String? title,
    String? time,
    List<int>? repeatDays,
    bool? isEnabled,
    String? category,
  }) {
    return CareReminder(
      id: id ?? this.id,
      birdId: birdId ?? this.birdId,
      title: title ?? this.title,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      category: category ?? this.category,
    );
  }
}
