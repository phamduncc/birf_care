import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../food/presentation/food_library_screen.dart';
import '../../knowledge/presentation/knowledge_base_screen.dart';
import '../../breeding/presentation/breeding_screen.dart';
import '../../reminders/presentation/reminders_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;
  const MoreScreen({super.key, this.onThemeChanged, this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công cụ & Mở rộng'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection(
            context,
            title: 'Tài nguyên & Hướng dẫn',
            items: [
              _MenuItem(
                icon: Icons.restaurant_menu,
                color: AppColors.safeGreen,
                title: 'Thư viện thức ăn chim',
                subtitle: 'Tra cứu 40+ thực phẩm an toàn, hạn chế & độc hại',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodLibraryScreen())),
              ),
              _MenuItem(
                icon: Icons.menu_book,
                color: AppColors.infoBlue,
                title: 'Thư viện kiến thức chăm sóc',
                subtitle: 'Cẩm nang dinh dưỡng, vệ sinh, sức khỏe & taming',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowledgeBaseScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            context,
            title: 'Công cụ nuôi & Nhân giống',
            items: [
              _MenuItem(
                icon: Icons.egg_outlined,
                color: AppColors.secondary,
                title: 'Theo dõi sinh sản & Ấp trứng',
                subtitle: 'Quản lý cặp phối giống, số trứng & ngày nở',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreedingScreen())),
              ),
              _MenuItem(
                icon: Icons.alarm,
                color: Colors.purple,
                title: 'Nhắc lịch chăm sóc',
                subtitle: 'Đặt thông báo local cho ăn, thay nước, dọn lồng',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            context,
            title: 'Hệ thống',
            items: [
              _MenuItem(
                icon: Icons.settings_outlined,
                color: Colors.blueGrey,
                title: 'Cài đặt & Sao lưu offline',
                subtitle: 'Đổi giao diện sáng/tối, xuất file zip sao lưu',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen(onThemeChanged: onThemeChanged, isDarkMode: isDarkMode)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, {required String title, required List<_MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: items.map((item) {
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: item.onTap,
                  ),
                  if (items.indexOf(item) != items.length - 1) const Divider(height: 1, indent: 60),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
