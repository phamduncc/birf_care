import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../birds/models/bird.dart';
import '../models/diary_entry.dart';

class AddDiaryScreen extends StatefulWidget {
  final Bird? bird;
  const AddDiaryScreen({super.key, this.bird});

  @override
  State<AddDiaryScreen> createState() => _AddDiaryScreenState();
}

class _AddDiaryScreenState extends State<AddDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  Bird? _selectedBird;
  List<Bird> _allBirds = [];
  String _date = DateTime.now().toString().split(' ')[0];
  final List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    _selectedBird = widget.bird;
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadBirds();
  }

  Future<void> _loadBirds() async {
    final list = await DatabaseHelper.instance.getBirds();
    setState(() {
      _allBirds = list;
      if (_selectedBird == null && list.isNotEmpty) {
        _selectedBird = list.first;
      }
    });
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _photoPaths.addAll(pickedFiles.map((f) => f.path));
      });
    }
  }

  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate() || _selectedBird == null) return;

    final entry = DiaryEntry(
      id: 'diary_${DateTime.now().millisecondsSinceEpoch}',
      birdId: _selectedBird!.id,
      date: _date,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      photoPaths: _photoPaths,
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertDiaryEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary entry saved'), backgroundColor: AppColors.safeGreen),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New diary entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveDiary,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Bird Dropdown
              if (_allBirds.isNotEmpty)
                DropdownButtonFormField<Bird>(
                  value: _selectedBird,
                  decoration: const InputDecoration(
                    labelText: 'Bird *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: _allBirds.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                  onChanged: (val) => setState(() => _selectedBird = val),
                ),
              const SizedBox(height: 16),

              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Entry date', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_date),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _date = picked.toString().split(' ')[0]);
                    }
                  },
                  child: const Text('Pick date'),
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Content
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Details *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter the diary text' : null,
              ),
              const SizedBox(height: 20),

              // Photos Picker & Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    onPressed: _pickPhotos,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Choose photos'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_photoPaths.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _photoPaths.length,
                  itemBuilder: (ctx, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_photoPaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _photoPaths.removeAt(index)),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _saveDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Save diary entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
