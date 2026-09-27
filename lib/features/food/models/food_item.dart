class FoodItem {
  final String id;
  final String name;
  final String? englishName;
  final String category; // Safe, Limit, Dangerous
  final String foodGroup; // Vegetables, Fruits, Seeds, Dangerous, etc.
  final String? portion;
  final String? preparation;
  final String? warnings;
  final String? description;

  FoodItem({
    required this.id,
    required this.name,
    this.englishName,
    required this.category,
    required this.foodGroup,
    this.portion,
    this.preparation,
    this.warnings,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'english_name': englishName,
      'category': category,
      'food_group': foodGroup,
      'portion': portion,
      'preparation': preparation,
      'warnings': warnings,
      'description': description,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as String,
      name: map['name'] as String,
      englishName: map['english_name'] as String?,
      category: map['category'] as String,
      foodGroup: map['food_group'] as String,
      portion: map['portion'] as String?,
      preparation: map['preparation'] as String?,
      warnings: map['warnings'] as String?,
      description: map['description'] as String?,
    );
  }
}
