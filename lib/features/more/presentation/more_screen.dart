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
        title: const Text('Tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection(
            context,
            title: 'Guides',
            items: [
              _MenuItem(
                icon: Icons.restaurant_menu,
                color: AppColors.safeGreen,
                title: 'Food library',
                subtitle: 'Safe, limited, and toxic foods',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodLibraryScreen())),
              ),
              _MenuItem(
                icon: Icons.menu_book,
                color: AppColors.infoBlue,
                title: 'Care guides',
                subtitle: 'Diet, hygiene, health, and taming',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowledgeBaseScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            context,
            title: 'Breeding tools',
            items: [
              _MenuItem(
                icon: Icons.egg_outlined,
                color: AppColors.secondary,
                title: 'Breeding and eggs',
                subtitle: 'Pairs, clutch size, and hatch dates',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreedingScreen())),
              ),
              _MenuItem(
                icon: Icons.alarm,
                color: Colors.purple,
                title: 'Care reminders',
                subtitle: 'Local alerts to feed, change water, and clean',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RemindersScreen())),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            context,
            title: 'System',
            items: [
              _MenuItem(
                icon: Icons.settings_outlined,
                color: Colors.blueGrey,
                title: 'Settings and backup',
                subtitle: 'Light or dark theme, and zip backup',
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
