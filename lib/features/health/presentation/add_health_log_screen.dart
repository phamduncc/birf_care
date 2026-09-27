import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../birds/models/bird.dart';
import '../models/health_log.dart';

class AddHealthLogScreen extends StatefulWidget {
  final Bird bird;
  const AddHealthLogScreen({super.key, required this.bird});

  @override
  State<AddHealthLogScreen> createState() => _AddHealthLogScreenState();
}

class _AddHealthLogScreenState extends State<AddHealthLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _featherController;
  late TextEditingController _beakLegsController;
  late TextEditingController _notesController;

  String _date = DateTime.now().toString().split(' ')[0];
  String _appetite = 'Good';
  String _waterIntake = 'Normal';
  String _activity = 'Good';
  String _droppings = 'Normal';

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.bird.weight?.toString() ?? '');
    _featherController = TextEditingController(text: 'Smooth, no unusual shedding');
    _beakLegsController = TextEditingController(text: 'Shiny beak, smooth leg scales');
    _notesController = TextEditingController();
  }

  Future<void> _saveLog() async {
    if (!_formKey.currentState!.validate()) return;

    final weightVal = double.tryParse(_weightController.text.trim());

    final log = HealthLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      birdId: widget.bird.id,
      date: _date,
      weight: weightVal,
      appetite: _appetite,
      waterIntake: _waterIntake,
      activity: _activity,
      droppings: _droppings,
      featherCondition: _featherController.text.trim().isEmpty ? null : _featherController.text.trim(),
      beakLegsCondition: _beakLegsController.text.trim().isEmpty ? null : _beakLegsController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertHealthLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health log saved'), backgroundColor: AppColors.safeGreen),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health log: ${widget.bird.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLog,
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
              // Date Selector
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Log date', style: TextStyle(fontWeight: FontWeight.bold)),
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

              // Weight Input
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Today’s weight (grams) *',
                  border: OutlineInputBorder(),
                  suffixText: 'g',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a weight';
                  if (double.tryParse(val.trim()) == null) return 'Enter a valid weight';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Appetite Choice
              const Text('Appetite:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildOptionChip('Poor', 'Poor', _appetite, (val) => setState(() => _appetite = val)),
                  const SizedBox(width: 8),
                  _buildOptionChip('Normal', 'Normal', _appetite, (val) => setState(() => _appetite = val)),
                  const SizedBox(width: 8),
                  _buildOptionChip('Good', 'Good', _appetite, (val) => setState(() => _appetite = val)),
                ],
              ),
              const SizedBox(height: 16),

              // Activity Choice
              const Text('Activity:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildOptionChip('Low', 'Poor', _activity, (val) => setState(() => _activity = val)),
                  const SizedBox(width: 8),
                  _buildOptionChip('Normal', 'Normal', _activity, (val) => setState(() => _activity = val)),
                  const SizedBox(width: 8),
                  _buildOptionChip('Active', 'Good', _activity, (val) => setState(() => _activity = val)),
                ],
              ),
              const SizedBox(height: 16),

              // Droppings Status
              const Text('Droppings:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildOptionChip('Normal', 'Normal', _droppings, (val) => setState(() => _droppings = val)),
                  const SizedBox(width: 8),
                  _buildOptionChip('Abnormal', 'Abnormal', _droppings, (val) => setState(() => _droppings = val)),
                ],
              ),
              const SizedBox(height: 20),

              // Feather & Beak inputs
              TextFormField(
                controller: _featherController,
                decoration: const InputDecoration(
                  labelText: 'Feather condition',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.blur_on),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _beakLegsController,
                decoration: const InputDecoration(
                  labelText: 'Beak, eyes, and feet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.remove_red_eye),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Extra health notes',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Save health log'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip(String label, String value, String currentValue, Function(String) onSelect) {
    final isSelected = currentValue == value;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        selectedColor: AppColors.primary.withOpacity(0.2),
        onSelected: (selected) {
          if (selected) onSelect(value);
        },
      ),
    );
  }
}
