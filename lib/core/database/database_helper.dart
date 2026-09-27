import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../features/birds/models/bird.dart';
import '../../features/health/models/health_log.dart';
import '../../features/diary/models/diary_entry.dart';
import '../../features/food/models/food_item.dart';
import '../../features/knowledge/models/article.dart';
import '../../features/reminders/models/care_reminder.dart';
import '../../features/breeding/models/breeding_pair.dart';
import '../../features/breeding/models/breeding_egg.dart';
import '../events/app_event_bus.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bird_care.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE birds (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        gender TEXT,
        birth_date TEXT,
        adopt_date TEXT,
        color TEXT,
        weight REAL,
        avatar_path TEXT,
        father_id TEXT,
        mother_id TEXT,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_logs (
        id TEXT PRIMARY KEY,
        bird_id TEXT NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        appetite TEXT,
        water_intake TEXT,
        activity TEXT,
        droppings TEXT,
        feather_condition TEXT,
        beak_legs_condition TEXT,
        notes TEXT,
        photo_path TEXT,
        created_at TEXT,
        FOREIGN KEY(bird_id) REFERENCES birds(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE diary_entries (
        id TEXT PRIMARY KEY,
        bird_id TEXT NOT NULL,
        date TEXT NOT NULL,
        title TEXT,
        content TEXT,
        photo_paths TEXT,
        created_at TEXT,
        FOREIGN KEY(bird_id) REFERENCES birds(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE foods (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        english_name TEXT,
        category TEXT NOT NULL,
        food_group TEXT NOT NULL,
        portion TEXT,
        preparation TEXT,
        warnings TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE articles (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        content TEXT NOT NULL,
        read_time_minutes INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        bird_id TEXT,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        repeat_days TEXT,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        category TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE breeding_pairs (
        id TEXT PRIMARY KEY,
        male_id TEXT NOT NULL,
        female_id TEXT NOT NULL,
        pair_date TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE breeding_eggs (
        id TEXT PRIMARY KEY,
        pair_id TEXT NOT NULL,
        egg_number INTEGER NOT NULL,
        laid_date TEXT NOT NULL,
        hatch_date TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        offspring_bird_id TEXT
      )
    ''');

    // Populate Initial Seed Data
    await SeedData.populateSeedData(db);
  }

  // --- BIRDS CRUD ---
  Future<List<Bird>> getBirds() async {
    final db = await instance.database;
    final result = await db.query('birds', orderBy: 'created_at DESC');
    return result.map((map) => Bird.fromMap(map)).toList();
  }

  Future<Bird?> getBirdById(String id) async {
    final db = await instance.database;
    final result = await db.query('birds', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Bird.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertBird(Bird bird) async {
    final db = await instance.database;
    final res = await db.insert('birds', bird.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    AppEventBus.instance.notify(AppDataChangeEvent.birds);
    return res;
  }

  Future<int> updateBird(Bird bird) async {
    final db = await instance.database;
    final res = await db.update('birds', bird.toMap(), where: 'id = ?', whereArgs: [bird.id]);
    AppEventBus.instance.notify(AppDataChangeEvent.birds);
    return res;
  }

  Future<int> deleteBird(String id) async {
    final db = await instance.database;
    final res = await db.delete('birds', where: 'id = ?', whereArgs: [id]);
    AppEventBus.instance.notify(AppDataChangeEvent.birds);
    return res;
  }

  // --- HEALTH LOGS CRUD ---
  Future<List<HealthLog>> getHealthLogs(String birdId) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (birdId.isNotEmpty) {
      result = await db.query(
        'health_logs',
        where: 'bird_id = ?',
        whereArgs: [birdId],
        orderBy: 'date DESC, created_at DESC',
      );
    } else {
      result = await db.query('health_logs', orderBy: 'date DESC, created_at DESC');
    }
    return result.map((map) => HealthLog.fromMap(map)).toList();
  }

  Future<int> insertHealthLog(HealthLog log) async {
    final db = await instance.database;
    // Update bird current weight if weight is provided
    if (log.weight != null) {
      await db.update('birds', {'weight': log.weight}, where: 'id = ?', whereArgs: [log.birdId]);
    }
    final res = await db.insert('health_logs', log.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    AppEventBus.instance.notify(AppDataChangeEvent.healthLogs);
    return res;
  }

  Future<int> deleteHealthLog(String id) async {
    final db = await instance.database;
    final res = await db.delete('health_logs', where: 'id = ?', whereArgs: [id]);
    AppEventBus.instance.notify(AppDataChangeEvent.healthLogs);
    return res;
  }

  // --- DIARY ENTRIES CRUD ---
  Future<List<DiaryEntry>> getDiaryEntries({String? birdId}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (birdId != null && birdId.isNotEmpty) {
      result = await db.query(
        'diary_entries',
        where: 'bird_id = ?',
        whereArgs: [birdId],
        orderBy: 'date DESC, created_at DESC',
      );
    } else {
      result = await db.query('diary_entries', orderBy: 'date DESC, created_at DESC');
    }
    return result.map((map) => DiaryEntry.fromMap(map)).toList();
  }

  Future<int> insertDiaryEntry(DiaryEntry entry) async {
    final db = await instance.database;
    final res = await db.insert('diary_entries', entry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    AppEventBus.instance.notify(AppDataChangeEvent.diary);
    return res;
  }

  Future<int> deleteDiaryEntry(String id) async {
    final db = await instance.database;
    final res = await db.delete('diary_entries', where: 'id = ?', whereArgs: [id]);
    AppEventBus.instance.notify(AppDataChangeEvent.diary);
    return res;
  }

  // --- FOODS CRUD ---
  Future<List<FoodItem>> getFoods({String? category, String? query}) async {
    final db = await instance.database;
    String? whereClause;
    List<dynamic> whereArgs = [];

    if (category != null && category != 'All') {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }

    if (query != null && query.trim().isNotEmpty) {
      if (whereClause != null) {
        whereClause += ' AND (name LIKE ? OR english_name LIKE ? OR food_group LIKE ?)';
      } else {
        whereClause = '(name LIKE ? OR english_name LIKE ? OR food_group LIKE ?)';
      }
      final searchPattern = '%${query.trim()}%';
      whereArgs.addAll([searchPattern, searchPattern, searchPattern]);
    }

    final result = await db.query('foods', where: whereClause, whereArgs: whereArgs.isNotEmpty ? whereArgs : null, orderBy: 'name ASC');
    return result.map((map) => FoodItem.fromMap(map)).toList();
  }

  // --- ARTICLES CRUD ---
  Future<List<Article>> getArticles({String? category}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (category != null && category != 'All') {
      result = await db.query('articles', where: 'category = ?', whereArgs: [category]);
    } else {
      result = await db.query('articles');
    }
    return result.map((map) => Article.fromMap(map)).toList();
  }

  // --- REMINDERS CRUD ---
  Future<List<CareReminder>> getReminders() async {
    final db = await instance.database;
    final result = await db.query('reminders', orderBy: 'time ASC');
    return result.map((map) => CareReminder.fromMap(map)).toList();
  }

  Future<int> insertReminder(CareReminder reminder) async {
    final db = await instance.database;
    final res = await db.insert('reminders', reminder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    AppEventBus.instance.notify(AppDataChangeEvent.reminders);
    return res;
  }

  Future<int> updateReminder(CareReminder reminder) async {
    final db = await instance.database;
    final res = await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
    AppEventBus.instance.notify(AppDataChangeEvent.reminders);
    return res;
  }

  Future<int> deleteReminder(String id) async {
    final db = await instance.database;
    final res = await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    AppEventBus.instance.notify(AppDataChangeEvent.reminders);
    return res;
  }

  // --- BREEDING CRUD ---
  Future<List<BreedingPair>> getBreedingPairs() async {
    final db = await instance.database;
    final result = await db.query('breeding_pairs', orderBy: 'pair_date DESC');
    return result.map((map) => BreedingPair.fromMap(map)).toList();
  }

  Future<int> insertBreedingPair(BreedingPair pair) async {
    final db = await instance.database;
    final res = await db.insert('breeding_pairs', pair.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    AppEventBus.instance.notify(AppDataChangeEvent.breeding);
    return res;
  }

  Future<List<BreedingEgg>> getEggsForPair(String pairId) async {
    final db = await instance.database;
    final result = await db.query('breeding_eggs', where: 'pair_id = ?', whereArgs: [pairId], orderBy: 'egg_number ASC');
    return result.map((map) => BreedingEgg.fromMap(map)).toList();
  }

  Future<int> insertBreedingEgg(BreedingEgg egg) async {
    final db = await instance.database;
    final res = await db.insert('breeding_eggs', egg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    AppEventBus.instance.notify(AppDataChangeEvent.breeding);
    return res;
  }

  Future<int> updateBreedingEgg(BreedingEgg egg) async {
    final db = await instance.database;
    final res = await db.update('breeding_eggs', egg.toMap(), where: 'id = ?', whereArgs: [egg.id]);
    AppEventBus.instance.notify(AppDataChangeEvent.breeding);
    return res;
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('health_logs');
    await db.delete('diary_entries');
    await db.delete('breeding_eggs');
    await db.delete('breeding_pairs');
    await db.delete('birds');
    await db.delete('reminders');
    AppEventBus.instance.notifyAll();
  }
}
