class BreedingEgg {
  final String id;
  final String pairId;
  final int eggNumber;
  final String laidDate;
  final String? hatchDate;
  final String status; // Incubating, Hatched, Infertile, Broken
  final String? notes;
  final String? offspringBirdId;

  BreedingEgg({
    required this.id,
    required this.pairId,
    required this.eggNumber,
    required this.laidDate,
    this.hatchDate,
    this.status = 'Incubating',
    this.notes,
    this.offspringBirdId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pair_id': pairId,
      'egg_number': eggNumber,
      'laid_date': laidDate,
      'hatch_date': hatchDate,
      'status': status,
      'notes': notes,
      'offspring_bird_id': offspringBirdId,
    };
  }

  factory BreedingEgg.fromMap(Map<String, dynamic> map) {
    return BreedingEgg(
      id: map['id'] as String,
      pairId: map['pair_id'] as String,
      eggNumber: (map['egg_number'] as num).toInt(),
      laidDate: map['laid_date'] as String,
      hatchDate: map['hatch_date'] as String?,
      status: (map['status'] as String?) ?? 'Incubating',
      notes: map['notes'] as String?,
      offspringBirdId: map['offspring_bird_id'] as String?,
    );
  }
}
