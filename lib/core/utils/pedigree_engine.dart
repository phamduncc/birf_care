import '../../features/birds/models/bird.dart';
import '../database/database_helper.dart';

class PedigreeNode {
  final Bird bird;
  final PedigreeNode? father;
  final PedigreeNode? mother;
  final List<Bird> offspring;

  PedigreeNode({
    required this.bird,
    this.father,
    this.mother,
    this.offspring = const [],
  });
}

class PedigreeEngine {
  /// Builds a pedigree node representation for a target bird
  static Future<PedigreeNode> buildPedigreeTree(Bird targetBird) async {
    final dbHelper = DatabaseHelper.instance;
    final allBirds = await dbHelper.getBirds();

    // Map for fast lookup
    final Map<String, Bird> birdMap = {for (var b in allBirds) b.id: b};

    Bird? father;
    Bird? mother;

    if (targetBird.fatherId != null && birdMap.containsKey(targetBird.fatherId)) {
      father = birdMap[targetBird.fatherId];
    }
    if (targetBird.motherId != null && birdMap.containsKey(targetBird.motherId)) {
      mother = birdMap[targetBird.motherId];
    }

    final offspring = allBirds.where((b) => b.fatherId == targetBird.id || b.motherId == targetBird.id).toList();

    return PedigreeNode(
      bird: targetBird,
      father: father != null ? PedigreeNode(bird: father) : null,
      mother: mother != null ? PedigreeNode(bird: mother) : null,
      offspring: offspring,
    );
  }
}
