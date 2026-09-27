import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/notifications/notification_service.dart';
import '../models/care_reminder.dart';

import 'dart:async';
import '../../../core/events/app_event_bus.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<CareReminder> _reminders = [];
  bool _isLoading = true;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _eventSubscription = AppEventBus.instance.stream.listen((event) {
      if (event == AppDataChangeEvent.reminders || event == AppDataChangeEvent.all) {
        _loadReminders();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.getReminders();
    setState(() {
      _reminders = list;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(CareReminder reminder) async {
    final updated = reminder.copyWith(isEnabled: !reminder.isEnabled);
    await DatabaseHelper.instance.updateReminder(updated);

    if (updated.isEnabled) {
      await NotificationService.instance.showNotification(
        id: updated.id.hashCode,
        title: '⏰ Chim Nhà: Nhắc lịch',
        body: updated.title,
      );
    } else {
      await NotificationService.instance.cancelNotification(updated.id.hashCode);
    }

    _loadReminders();
  }

  void _showAddEditDialog([CareReminder? reminder]) {
    final isEditing = reminder != null;
    final titleController = TextEditingController(text: reminder?.title ?? '');
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);

    if (reminder != null) {
      final parts = reminder.time.split(':');
      if (parts.length == 2) {
        selectedTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 8, minute: int.tryParse(parts[1]) ?? 0);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Chỉnh sửa nhắc lịch' : 'Thêm nhắc lịch mới'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề nhắc nhở *',
                      hintText: 'Cho Bông ăn, Thay nước...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Giờ nhắc'),
                    trailing: Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(context: context, initialTime: selectedTime);
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;

                    final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    final item = CareReminder(
                      id: reminder?.id ?? 'rem_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      time: timeStr,
                      category: 'Custom',
                    );

                    if (isEditing) {
                      await DatabaseHelper.instance.updateReminder(item);
                    } else {
                      await DatabaseHelper.instance.insertReminder(item);
                    }

                    if (mounted) Navigator.pop(ctx);
                    _loadReminders();
                  },
                  child: const Text('Lưu'),
                ),
              ],
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
        title: const Text('Nhắc lịch chăm sóc (Local)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? const Center(child: Text('Chưa có lịch nhắc nhở nào', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    final item = _reminders[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.isEnabled ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                          child: Icon(
                            Icons.alarm,
                            color: item.isEnabled ? AppColors.primary : Colors.grey,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.isEnabled ? null : Colors.grey,
                          ),
                        ),
                        subtitle: Text('Hàng ngày vào lúc ${item.time}', style: const TextStyle(fontSize: 12)),
                        trailing: Switch(
                          value: item.isEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (_) => _toggleReminder(item),
                        ),
                        onLongPress: () => _showAddEditDialog(item),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_reminders',
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}
