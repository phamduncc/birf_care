class BreedingPair {
  final String id;
  final String maleId;
  final String femaleId;
  final String pairDate;
  final String status; // Active, Paused, Separated
  final String? notes;

  BreedingPair({
    required this.id,
    required this.maleId,
    required this.femaleId,
    required this.pairDate,
    this.status = 'Active',
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'male_id': maleId,
      'female_id': femaleId,
      'pair_date': pairDate,
      'status': status,
      'notes': notes,
    };
  }

  factory BreedingPair.fromMap(Map<String, dynamic> map) {
    return BreedingPair(
      id: map['id'] as String,
      maleId: map['male_id'] as String,
      femaleId: map['female_id'] as String,
      pairDate: map['pair_date'] as String,
      status: (map['status'] as String?) ?? 'Active',
      notes: map['notes'] as String?,
    );
  }
}
