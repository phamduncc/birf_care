import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/backup_restore_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;
  const SettingsScreen({super.key, this.onThemeChanged, this.isDarkMode = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;

  Future<void> _exportBackup() async {
    setState(() => _isExporting = true);
    try {
      final zipFile = await BackupRestoreService.createBackupZip();
      if (mounted) {
        await Share.shareXFiles(
          [XFile(zipFile.path)],
          text: 'Sao lưu dữ liệu Chim Nhà (100% Offline Backup)',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi sao lưu: $e'), backgroundColor: AppColors.dangerRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _resetAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đặt lại dữ liệu'),
        content: const Text('⚠️ Tất cả hồ sơ chim, nhật ký sức khỏe, nhật ký ảnh và lịch nhắc nhở sẽ bị xóa hoàn toàn. Bạn có chắc chắn?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed),
            child: const Text('Xóa toàn bộ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đặt lại dữ liệu sạch thành công!'), backgroundColor: AppColors.safeGreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Quyền riêng tư'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Offline Guarantee Card
          Card(
            color: AppColors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 36, color: AppColors.primary),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('100% Offline & Bảo mật', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2),
                        Text(
                          'Dữ liệu của bạn nằm hoàn toàn trên thiết bị này. Không đăng nhập, không máy chủ, không thu thập dữ liệu.',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text('Giao diện & Cài đặt', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              secondary: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Chế độ Tối (Dark Mode)'),
              value: widget.isDarkMode,
              onChanged: (val) {
                if (widget.onThemeChanged != null) {
                  widget.onThemeChanged!(val);
                }
              },
            ),
          ),

          const SizedBox(height: 20),
          const Text('Sao lưu & Phục hồi dữ liệu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                  title: const Text('Xuất file Sao lưu (.zip)'),
                  subtitle: const Text('Lưu file nén chứa DB & ảnh lên Google Drive, Zalo hoặc máy tính'),
                  trailing: _isExporting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right),
                  onTap: _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever_outlined, color: AppColors.dangerRed),
                  title: const Text('Đặt lại toàn bộ dữ liệu'),
                  subtitle: const Text('Xóa sạch dữ liệu thử nghiệm về ban đầu'),
                  onTap: _resetAllData,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // About section
          const Center(
            child: Column(
              children: [
                Text('🐦 Chim Nhà Offline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Phiên bản 1.0.0 (Release Build)', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
