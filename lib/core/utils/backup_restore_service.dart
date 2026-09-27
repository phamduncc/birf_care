import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';
import '../../features/birds/models/bird.dart';
import '../../features/health/models/health_log.dart';
import '../../features/diary/models/diary_entry.dart';
import '../../features/reminders/models/care_reminder.dart';
import '../../features/breeding/models/breeding_pair.dart';

class BackupRestoreService {
  /// Export all user data (birds, health logs, diary, breeding, reminders) into a JSON backup file
  static Future<File> createBackupZip() async {
    final dbHelper = DatabaseHelper.instance;

    final birds = await dbHelper.getBirds();
    final healthLogs = await dbHelper.getHealthLogs('');
    final diaryEntries = await dbHelper.getDiaryEntries();
    final reminders = await dbHelper.getReminders();
    final pairs = await dbHelper.getBreedingPairs();

    final Map<String, dynamic> backupData = {
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'birds': birds.map((b) => b.toMap()).toList(),
      'health_logs': healthLogs.map((h) => h.toMap()).toList(),
      'diary_entries': diaryEntries.map((d) => d.toMap()).toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
      'breeding_pairs': pairs.map((p) => p.toMap()).toList(),
    };

    final jsonString = jsonEncode(backupData);

    final archive = Archive();
    archive.addFile(ArchiveFile('data.json', jsonString.length, utf8.encode(jsonString)));

    final encoder = ZipEncoder();
    final zipData = encoder.encode(archive);

    final tempDir = await getTemporaryDirectory();
    final dateStr = DateTime.now().toString().split(' ')[0].replaceAll('-', '');
    final backupFile = File(join(tempDir.path, 'ChimNha_Backup_$dateStr.zip'));

    if (zipData != null) {
      await backupFile.writeAsBytes(zipData);
    }
    return backupFile;
  }

  /// Restore data from JSON backup map
  static Future<bool> restoreFromMap(Map<String, dynamic> data) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.clearAllData();

      if (data['birds'] != null) {
        for (var map in data['birds']) {
          await dbHelper.insertBird(Bird.fromMap(map));
        }
      }
      if (data['health_logs'] != null) {
        for (var map in data['health_logs']) {
          await dbHelper.insertHealthLog(HealthLog.fromMap(map));
        }
      }
      if (data['diary_entries'] != null) {
        for (var map in data['diary_entries']) {
          await dbHelper.insertDiaryEntry(DiaryEntry.fromMap(map));
        }
      }
      if (data['reminders'] != null) {
        for (var map in data['reminders']) {
          await dbHelper.insertReminder(CareReminder.fromMap(map));
        }
      }
      if (data['breeding_pairs'] != null) {
        for (var map in data['breeding_pairs']) {
          await dbHelper.insertBreedingPair(BreedingPair.fromMap(map));
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restore data from a ZIP file containing data.json
  static Future<bool> restoreFromZip(File zipFile) async {
    try {
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final dataFile = archive.findFile('data.json');
      if (dataFile == null) return false;

      final jsonStr = utf8.decode(dataFile.content as List<int>);
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      return await restoreFromMap(data);
    } catch (e) {
      return false;
    }
  }
}
