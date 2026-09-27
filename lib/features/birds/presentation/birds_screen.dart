import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../models/bird.dart';
import 'add_edit_bird_screen.dart';
import 'bird_detail_screen.dart';

import 'dart:async';
import '../../../core/events/app_event_bus.dart';

class BirdsScreen extends StatefulWidget {
  const BirdsScreen({super.key});

  @override
  State<BirdsScreen> createState() => _BirdsScreenState();
}

class _BirdsScreenState extends State<BirdsScreen> {
  List<Bird> _birds = [];
  bool _isLoading = true;
  String _searchQuery = '';
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadBirds();
    _eventSubscription = AppEventBus.instance.stream.listen((event) {
      if (event == AppDataChangeEvent.birds || event == AppDataChangeEvent.all) {
        _loadBirds();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBirds() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.getBirds();
    setState(() {
      _birds = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBirds = _birds.where((b) {
      final query = _searchQuery.toLowerCase();
      return b.name.toLowerCase().contains(query) || b.species.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My birds'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or species...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Bird Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBirds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🐦', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 12),
                            Text(
                              _birds.isEmpty ? 'No birds yet' : 'No matching birds',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddEditBirdScreen()),
                                ).then((_) => _loadBirds());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add your first bird'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: filteredBirds.length,
                        itemBuilder: (context, index) {
                          final bird = filteredBirds[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: AppColors.primary.withOpacity(0.15),
                                backgroundImage: bird.avatarPath != null ? FileImage(File(bird.avatarPath!)) : null,
                                child: bird.avatarPath == null ? const Text('🐦', style: TextStyle(fontSize: 24)) : null,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    bird.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: bird.gender == 'Male'
                                          ? AppColors.infoBlue.withOpacity(0.15)
                                          : (bird.gender == 'Female' ? Colors.pink.withOpacity(0.15) : Colors.grey.withOpacity(0.15)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      bird.gender,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: bird.gender == 'Male' ? AppColors.infoBlue : (bird.gender == 'Female' ? Colors.pink : Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${bird.species}${bird.weight != null ? " • ${bird.weight!.toStringAsFixed(1)}g" : ""}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => BirdDetailScreen(bird: bird)),
                                ).then((_) => _loadBirds());
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_birds',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditBirdScreen()),
          ).then((_) => _loadBirds());
        },
        icon: const Icon(Icons.add),
        label: const Text('Add bird'),
      ),
    );
  }
}
