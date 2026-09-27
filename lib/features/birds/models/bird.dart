class Bird {
  final String id;
  final String name;
  final String species;
  final String gender; // Male, Female, Unknown
  final String? birthDate;
  final String? adoptDate;
  final String? color;
  final double? weight; // current or initial weight in grams
  final String? avatarPath;
  final String? fatherId;
  final String? motherId;
  final String? notes;
  final String createdAt;

  Bird({
    required this.id,
    required this.name,
    required this.species,
    this.gender = 'Unknown',
    this.birthDate,
    this.adoptDate,
    this.color,
    this.weight,
    this.avatarPath,
    this.fatherId,
    this.motherId,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'gender': gender,
      'birth_date': birthDate,
      'adopt_date': adoptDate,
      'color': color,
      'weight': weight,
      'avatar_path': avatarPath,
      'father_id': fatherId,
      'mother_id': motherId,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Bird.fromMap(Map<String, dynamic> map) {
    return Bird(
      id: map['id'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      gender: (map['gender'] as String?) ?? 'Unknown',
      birthDate: map['birth_date'] as String?,
      adoptDate: map['adopt_date'] as String?,
      color: map['color'] as String?,
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      avatarPath: map['avatar_path'] as String?,
      fatherId: map['father_id'] as String?,
      motherId: map['mother_id'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Bird copyWith({
    String? id,
    String? name,
    String? species,
    String? gender,
    String? birthDate,
    String? adoptDate,
    String? color,
    double? weight,
    String? avatarPath,
    String? fatherId,
    String? motherId,
    String? notes,
    String? createdAt,
  }) {
    return Bird(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      adoptDate: adoptDate ?? this.adoptDate,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      avatarPath: avatarPath ?? this.avatarPath,
      fatherId: fatherId ?? this.fatherId,
      motherId: motherId ?? this.motherId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
