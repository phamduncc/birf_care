import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/notifications/notification_service.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/birds/presentation/birds_screen.dart';
import 'features/diary/presentation/diary_screen.dart';
import 'features/more/presentation/more_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const ChimNhaApp());
}

class ChimNhaApp extends StatefulWidget {
  const ChimNhaApp({super.key});

  @override
  State<ChimNhaApp> createState() => _ChimNhaAppState();
}

class _ChimNhaAppState extends State<ChimNhaApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chim Nhà - Sổ Chăm Sóc Chim Offline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainNavigationContainer(
        onThemeChanged: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;

  const MainNavigationContainer({
    super.key,
    this.onThemeChanged,
    this.isDarkMode = false,
  });

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onNavigateToBirds: () => setState(() => _currentIndex = 1)),
      const BirdsScreen(),
      const DiaryScreen(),
      MoreScreen(onThemeChanged: widget.onThemeChanged, isDarkMode: widget.isDarkMode),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Chim nuôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Nhật ký',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Mở rộng',
          ),
        ],
      ),
    );
  }
}
