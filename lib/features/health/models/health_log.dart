class HealthLog {
  final String id;
  final String birdId;
  final String date; // YYYY-MM-DD
  final double? weight;
  final String appetite; // Poor, Normal, Good
  final String waterIntake; // Poor, Normal, Good
  final String activity; // Poor, Normal, Good
  final String droppings; // Normal, Abnormal
  final String? featherCondition;
  final String? beakLegsCondition;
  final String? notes;
  final String? photoPath;
  final String createdAt;

  HealthLog({
    required this.id,
    required this.birdId,
    required this.date,
    this.weight,
    this.appetite = 'Normal',
    this.waterIntake = 'Normal',
    this.activity = 'Normal',
    this.droppings = 'Normal',
    this.featherCondition,
    this.beakLegsCondition,
    this.notes,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bird_id': birdId,
      'date': date,
      'weight': weight,
      'appetite': appetite,
      'water_intake': waterIntake,
      'activity': activity,
      'droppings': droppings,
      'feather_condition': featherCondition,
      'beak_legs_condition': beakLegsCondition,
      'notes': notes,
      'photo_path': photoPath,
      'created_at': createdAt,
    };
  }

  factory HealthLog.fromMap(Map<String, dynamic> map) {
    return HealthLog(
      id: map['id'] as String,
      birdId: map['bird_id'] as String,
      date: map['date'] as String,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      appetite: (map['appetite'] as String?) ?? 'Normal',
      waterIntake: (map['water_intake'] as String?) ?? 'Normal',
      activity: (map['activity'] as String?) ?? 'Normal',
      droppings: (map['droppings'] as String?) ?? 'Normal',
      featherCondition: map['feather_condition'] as String?,
      beakLegsCondition: map['beak_legs_condition'] as String?,
      notes: map['notes'] as String?,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
