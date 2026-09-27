import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../models/bird.dart';

class AddEditBirdScreen extends StatefulWidget {
  final Bird? bird;
  const AddEditBirdScreen({super.key, this.bird});

  @override
  State<AddEditBirdScreen> createState() => _AddEditBirdScreenState();
}

class _AddEditBirdScreenState extends State<AddEditBirdScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _colorController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;

  String _gender = 'Mái';
  String? _birthDate;
  String? _adoptDate;
  String? _avatarPath;
  Bird? _selectedFather;
  Bird? _selectedMother;

  List<Bird> _existingBirds = [];

  final List<String> _commonSpecies = [
    'Yến phụng (Budgerigar)',
    'Lovebird (Mẫu đơn)',
    'Cockatiel (Vẹt má hồng)',
    'Finch (Chim sẻ cảnh)',
    'Canary (Yến hót)',
    'Vẹt Sun Conure',
    'Vẹt Monk / Quaker',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.bird;
    _nameController = TextEditingController(text: b?.name ?? '');
    _speciesController = TextEditingController(text: b?.species ?? _commonSpecies.first);
    _colorController = TextEditingController(text: b?.color ?? '');
    _weightController = TextEditingController(text: b?.weight?.toString() ?? '');
    _notesController = TextEditingController(text: b?.notes ?? '');

    if (b != null) {
      _gender = b.gender;
      _birthDate = b.birthDate;
      _adoptDate = b.adoptDate;
      _avatarPath = b.avatarPath;
    }
    _loadExistingBirds();
  }

  Future<void> _loadExistingBirds() async {
    final list = await DatabaseHelper.instance.getBirds();
    setState(() {
      _existingBirds = list.where((bird) => bird.id != widget.bird?.id).toList();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _avatarPath = pickedFile.path;
      });
    }
  }

  Future<void> _saveBird() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.bird?.id ?? 'bird_${DateTime.now().millisecondsSinceEpoch}';
    final weightVal = double.tryParse(_weightController.text.trim());

    final newBird = Bird(
      id: id,
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      adoptDate: _adoptDate ?? DateTime.now().toString().split(' ')[0],
      color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      weight: weightVal,
      avatarPath: _avatarPath,
      fatherId: _selectedFather?.id ?? widget.bird?.fatherId,
      motherId: _selectedMother?.id ?? widget.bird?.motherId,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.bird?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (widget.bird == null) {
      await DatabaseHelper.instance.insertBird(newBird);
    } else {
      await DatabaseHelper.instance.updateBird(newBird);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bird != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh sửa thông tin chim' : 'Thêm chú chim mới'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveBird,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Avatar Picker
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                  child: _avatarPath == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 30, color: AppColors.primary),
                            SizedBox(height: 4),
                            Text('Thêm ảnh', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên chim *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên chú chim' : null,
              ),
              const SizedBox(height: 16),

              // Species Dropdown / Autocomplete
              DropdownButtonFormField<String>(
                value: _commonSpecies.contains(_speciesController.text) ? _speciesController.text : 'Khác',
                decoration: const InputDecoration(
                  labelText: 'Loài chim *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _commonSpecies.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      if (val != 'Khác') {
                        _speciesController.text = val;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Gender Selector
              Row(
                children: [
                  const Text('Giới tính:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('♂ Trống'),
                    selected: _gender == 'Trống',
                    selectedColor: AppColors.infoBlue.withOpacity(0.2),
                    onSelected: (selected) {
                      if (selected) setState(() => _gender = 'Trống');
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('♀ Mái'),
                    selected: _gender == 'Mái',
                    selectedColor: Colors.pink.withOpacity(0.2),
                    onSelected: (selected) {
                      if (selected) setState(() => _gender = 'Mái');
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Chưa rõ'),
                    selected: _gender == 'Unknown',
                    onSelected: (selected) {
                      if (selected) setState(() => _gender = 'Unknown');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weight & Color
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cân nặng (g)',
                        border: OutlineInputBorder(),
                        suffixText: 'g',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Màu sắc / Đột biến',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.palette),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Parent Selection (Pedigree)
              if (_existingBirds.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Bird>(
                        value: _selectedFather,
                        decoration: const InputDecoration(
                          labelText: 'Chim Bố (♂)',
                          border: OutlineInputBorder(),
                        ),
                        items: _existingBirds
                            .where((b) => b.gender == 'Trống' || b.gender == 'Unknown')
                            .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedFather = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<Bird>(
                        value: _selectedMother,
                        decoration: const InputDecoration(
                          labelText: 'Chim Mẹ (♀)',
                          border: OutlineInputBorder(),
                        ),
                        items: _existingBirds
                            .where((b) => b.gender == 'Mái' || b.gender == 'Unknown')
                            .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedMother = val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú & Nguồn gốc',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveBird,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Lưu cập nhật' : 'Lưu chú chim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
