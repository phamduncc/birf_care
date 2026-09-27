import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../birds/models/bird.dart';
import '../models/diary_entry.dart';
import 'add_diary_screen.dart';

import 'dart:async';
import '../../../core/events/app_event_bus.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<DiaryEntry> _entries = [];
  Map<String, Bird> _birdMap = {};
  bool _isLoading = true;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _eventSubscription = AppEventBus.instance.stream.listen((event) {
      if (event == AppDataChangeEvent.diary || event == AppDataChangeEvent.birds || event == AppDataChangeEvent.all) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final birds = await DatabaseHelper.instance.getBirds();
    final map = {for (var b in birds) b.id: b};
    final diary = await DatabaseHelper.instance.getDiaryEntries();

    setState(() {
      _birdMap = map;
      _entries = diary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký ảnh & Kỷ niệm'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Chưa có nhật ký kỷ niệm nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddDiaryScreen()),
                          ).then((_) => _loadData());
                        },
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Tạo nhật ký đầu tiên'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final bird = _birdMap[entry.birdId];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: const Text('🐦', style: TextStyle(fontSize: 16)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bird?.name ?? 'Chim',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      entry.date,
                                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                  onPressed: () async {
                                    await DatabaseHelper.instance.deleteDiaryEntry(entry.id);
                                    _loadData();
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            Text(
                              entry.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.content,
                              style: const TextStyle(fontSize: 14),
                            ),

                            if (entry.photoPaths.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: entry.photoPaths.length,
                                  itemBuilder: (ctx, pIdx) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(entry.photoPaths[pIdx]),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_diary',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDiaryScreen()),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Thêm nhật ký'),
      ),
    );
  }
}
