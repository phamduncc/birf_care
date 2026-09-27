import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/pedigree_engine.dart';
import '../models/bird.dart';
import '../../health/models/health_log.dart';
import '../../diary/models/diary_entry.dart';
import 'dart:async';
import '../../../core/events/app_event_bus.dart';
import 'add_edit_bird_screen.dart';
import '../../health/presentation/add_health_log_screen.dart';

class BirdDetailScreen extends StatefulWidget {
  final Bird bird;
  const BirdDetailScreen({super.key, required this.bird});

  @override
  State<BirdDetailScreen> createState() => _BirdDetailScreenState();
}

class _BirdDetailScreenState extends State<BirdDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Bird _bird;
  List<HealthLog> _healthLogs = [];
  List<DiaryEntry> _diaryEntries = [];
  PedigreeNode? _pedigree;
  bool _isLoading = true;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _bird = widget.bird;
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
    _eventSubscription = AppEventBus.instance.stream.listen((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final freshBird = await DatabaseHelper.instance.getBirdById(_bird.id);
    if (freshBird != null) {
      _bird = freshBird;
    }

    final logs = await DatabaseHelper.instance.getHealthLogs(_bird.id);
    final diary = await DatabaseHelper.instance.getDiaryEntries(birdId: _bird.id);
    final ped = await PedigreeEngine.buildPedigreeTree(_bird);

    setState(() {
      _healthLogs = logs;
      _diaryEntries = diary;
      _pedigree = ped;
      _isLoading = false;
    });
  }

  Future<void> _deleteBird() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete bird'),
        content: Text('Delete all data for "${_bird.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteBird(_bird.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bird.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditBirdScreen(bird: _bird)),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteBird,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Weight'),
            Tab(text: 'Diary'),
            Tab(text: 'Pedigree'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBioTab(),
                _buildWeightTab(),
                _buildDiaryTab(),
                _buildPedigreeTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_bird_detail',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddHealthLogScreen(bird: _bird)),
          ).then((_) => _loadData());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- TAB 1: BIO / INFO ---
  Widget _buildBioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Hero Avatar Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    backgroundImage: _bird.avatarPath != null ? FileImage(File(_bird.avatarPath!)) : null,
                    child: _bird.avatarPath == null ? const Text('🐦', style: TextStyle(fontSize: 40)) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_bird.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_bird.species, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sex: ${_bird.gender}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Details List
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                _buildInfoRow(Icons.monitor_weight_outlined, 'Current weight', '${_bird.weight?.toStringAsFixed(1) ?? "--"} g'),
                const Divider(height: 1),
                _buildInfoRow(Icons.palette_outlined, 'Color / mutation', _bird.color ?? 'Not recorded'),
                const Divider(height: 1),
                _buildInfoRow(Icons.calendar_today_outlined, 'Adopted', _bird.adoptDate ?? 'Not recorded'),
                const Divider(height: 1),
                _buildInfoRow(Icons.cake_outlined, 'Hatch date', _bird.birthDate ?? 'Not recorded'),
                const Divider(height: 1),
                _buildInfoRow(Icons.notes_outlined, 'Notes', _bird.notes ?? 'No notes'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: WEIGHT CHART ---
  Widget _buildWeightTab() {
    final weightLogs = _healthLogs.where((l) => l.weight != null && l.weight! > 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (weightLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('No weight data yet', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddHealthLogScreen(bird: _bird)),
                ).then((_) => _loadData());
              },
              child: const Text('Log weight'),
            ),
          ],
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < weightLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), weightLogs[i].weight!));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight chart (g)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            height: 240,
            padding: const EdgeInsets.only(right: 16, left: 8, top: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        int index = val.toInt();
                        if (index >= 0 && index < weightLogs.length) {
                          final dateParts = weightLogs[index].date.split('-');
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              '${dateParts[1]}/${dateParts[2]}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Log history', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _healthLogs.length,
            itemBuilder: (context, index) {
              final log = _healthLogs[index];
              return Card(
                child: ListTile(
                  title: Text(log.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Appetite: ${log.appetite} • Activity: ${log.activity} • Droppings: ${log.droppings}'),
                  trailing: Text(
                    log.weight != null ? '${log.weight!.toStringAsFixed(1)} g' : '--',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 3: DIARY ---
  Widget _buildDiaryTab() {
    if (_diaryEntries.isEmpty) {
      return const Center(
        child: Text('No diary entries for this bird yet', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _diaryEntries.length,
      itemBuilder: (context, index) {
        final entry = _diaryEntries[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(entry.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(entry.content),
                if (entry.photoPaths.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: entry.photoPaths.length,
                      itemBuilder: (ctx, pIdx) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(entry.photoPaths[pIdx]),
                              width: 90,
                              height: 90,
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
    );
  }

  // --- TAB 4: PEDIGREE TREE ---
  Widget _buildPedigreeTab() {
    if (_pedigree == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pedigree', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Parents Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildFamilyCard(
                          title: 'Father',
                          bird: _pedigree!.father?.bird,
                          color: AppColors.infoBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildFamilyCard(
                          title: 'Mother',
                          bird: _pedigree!.mother?.bird,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.south, color: AppColors.primary),
                  const SizedBox(height: 16),
                  // Target Bird Card
                  _buildFamilyCard(
                    title: 'This bird',
                    bird: _bird,
                    color: AppColors.primary,
                    isMain: true,
                  ),
                  const SizedBox(height: 16),
                  if (_pedigree!.offspring.isNotEmpty) ...[
                    const Icon(Icons.south, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text('Offspring', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _pedigree!.offspring.map((child) {
                        return Chip(
                          avatar: const Text('🐣'),
                          label: Text(child.name),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyCard({
    required String title,
    required Bird? bird,
    required Color color,
    bool isMain = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(isMain ? 0.8 : 0.3), width: isMain ? 2 : 1),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            bird != null ? bird.name : 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          if (bird != null)
            Text(
              bird.species,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
