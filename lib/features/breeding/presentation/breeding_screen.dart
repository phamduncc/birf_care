import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../birds/models/bird.dart';
import '../models/breeding_pair.dart';
import '../models/breeding_egg.dart';

import 'dart:async';
import '../../../core/events/app_event_bus.dart';

class BreedingScreen extends StatefulWidget {
  const BreedingScreen({super.key});

  @override
  State<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends State<BreedingScreen> {
  List<BreedingPair> _pairs = [];
  Map<String, Bird> _birdMap = {};
  bool _isLoading = true;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadBreedingData();
    _eventSubscription = AppEventBus.instance.stream.listen((event) {
      if (event == AppDataChangeEvent.breeding || event == AppDataChangeEvent.birds || event == AppDataChangeEvent.all) {
        _loadBreedingData();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadBreedingData() async {
    setState(() => _isLoading = true);
    final birds = await DatabaseHelper.instance.getBirds();
    final map = {for (var b in birds) b.id: b};
    final list = await DatabaseHelper.instance.getBreedingPairs();

    setState(() {
      _birdMap = map;
      _pairs = list;
      _isLoading = false;
    });
  }

  void _showAddPairDialog() async {
    final birds = await DatabaseHelper.instance.getBirds();
    Bird? selectedMale;
    Bird? selectedFemale;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New breeding pair'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Bird>(
                    decoration: const InputDecoration(labelText: 'Father'),
                    items: birds.where((b) => b.gender == 'Male' || b.gender == 'Unknown').map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                    onChanged: (val) => setDialogState(() => selectedMale = val),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Bird>(
                    decoration: const InputDecoration(labelText: 'Mother'),
                    items: birds.where((b) => b.gender == 'Female' || b.gender == 'Unknown').map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                    onChanged: (val) => setDialogState(() => selectedFemale = val),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMale == null || selectedFemale == null) return;
                    final pair = BreedingPair(
                      id: 'pair_${DateTime.now().millisecondsSinceEpoch}',
                      maleId: selectedMale!.id,
                      femaleId: selectedFemale!.id,
                      pairDate: DateTime.now().toString().split(' ')[0],
                    );
                    await DatabaseHelper.instance.insertBreedingPair(pair);
                    if (mounted) Navigator.pop(ctx);
                    _loadBreedingData();
                  },
                  child: const Text('Create pair'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEggsModal(BreedingPair pair) async {
    List<BreedingEgg> eggs = await DatabaseHelper.instance.getEggsForPair(pair.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final male = _birdMap[pair.maleId];
            final female = _birdMap[pair.femaleId];

            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clutch: ${male?.name ?? "Father"} x ${female?.name ?? "Mother"}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Eggs: ${eggs.length}'),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final newEgg = BreedingEgg(
                            id: 'egg_${DateTime.now().millisecondsSinceEpoch}',
                            pairId: pair.id,
                            eggNumber: eggs.length + 1,
                            laidDate: DateTime.now().toString().split(' ')[0],
                            status: 'Incubating',
                          );
                          await DatabaseHelper.instance.insertBreedingEgg(newEgg);
                          final updated = await DatabaseHelper.instance.getEggsForPair(pair.id);
                          setModalState(() => eggs = updated);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add egg'),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  if (eggs.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No eggs recorded yet'))),
                  ...eggs.map((egg) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(backgroundColor: Colors.amber, child: Text('🥚')),
                      title: Text('Egg #${egg.eggNumber} • Laid ${egg.laidDate}'),
                      subtitle: Text('Status: ${egg.status}'),
                      trailing: DropdownButton<String>(
                        value: egg.status,
                        items: const [
                          DropdownMenuItem(value: 'Incubating', child: Text('Incubating')),
                          DropdownMenuItem(value: 'Hatched', child: Text('Hatched')),
                          DropdownMenuItem(value: 'Infertile', child: Text('Infertile')),
                          DropdownMenuItem(value: 'Broken', child: Text('Broken')),
                        ],
                        onChanged: (val) async {
                          if (val != null) {
                            final updatedEgg = BreedingEgg(
                              id: egg.id,
                              pairId: egg.pairId,
                              eggNumber: egg.eggNumber,
                              laidDate: egg.laidDate,
                              status: val,
                              hatchDate: val == 'Hatched' ? DateTime.now().toString().split(' ')[0] : egg.hatchDate,
                            );
                            await DatabaseHelper.instance.updateBreedingEgg(updatedEgg);
                            final updatedList = await DatabaseHelper.instance.getEggsForPair(pair.id);
                            setModalState(() => eggs = updatedList);
                          }
                        },
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding and eggs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pairs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🥚', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 12),
                      const Text('No breeding pairs yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddPairDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add the first pair'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _pairs.length,
                  itemBuilder: (context, index) {
                    final pair = _pairs[index];
                    final male = _birdMap[pair.maleId];
                    final female = _birdMap[pair.femaleId];

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Breeding pair', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Chip(
                                  label: Text(pair.status),
                                  backgroundColor: AppColors.safeGreen.withOpacity(0.15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildParentTile('Father', male?.name ?? 'Unknown', AppColors.infoBlue),
                                ),
                                const Text(' ❤️ ', style: TextStyle(fontSize: 20)),
                                Expanded(
                                  child: _buildParentTile('Mother', female?.name ?? 'Unknown', Colors.pink),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Paired on ${pair.pairDate}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                TextButton.icon(
                                  onPressed: () => _showEggsModal(pair),
                                  icon: const Icon(Icons.egg_outlined),
                                  label: const Text('Manage eggs'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_breeding',
        onPressed: _showAddPairDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add pair'),
      ),
    );
  }

  Widget _buildParentTile(String title, String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
