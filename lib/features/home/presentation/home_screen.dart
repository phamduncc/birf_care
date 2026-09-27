import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/health_rule_engine.dart';
import '../../birds/models/bird.dart';
import '../../birds/presentation/bird_detail_screen.dart';
import '../../birds/presentation/add_edit_bird_screen.dart';
import '../../health/presentation/add_health_log_screen.dart';
import '../../diary/presentation/add_diary_screen.dart';
import '../../food/presentation/food_library_screen.dart';

import 'dart:async';
import '../../../core/events/app_event_bus.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToBirds;
  const HomeScreen({super.key, this.onNavigateToBirds});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Bird? _selectedBird;
  List<Bird> _allBirds = [];
  List<HealthAlert> _alerts = [];
  bool _isLoading = true;
  StreamSubscription? _eventSubscription;

  // Daily checklist state
  final Map<String, bool> _todayChecklist = {
    'Feed (seeds and fresh greens)': false,
    'Change the drinking water': false,
    'Clean the tray liner': false,
    'Sunbath or water bath': false,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _eventSubscription = AppEventBus.instance.stream.listen((_) {
      _loadDashboardData();
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final birds = await DatabaseHelper.instance.getBirds();
    if (birds.isNotEmpty) {
      _allBirds = birds;
      _selectedBird = birds.first;

      final logs = await DatabaseHelper.instance.getHealthLogs(_selectedBird!.id);
      _alerts = HealthRuleEngine.evaluateLogs(logs);
    }
    setState(() => _isLoading = false);
  }

  void _switchBird(Bird bird) async {
    setState(() {
      _selectedBird = bird;
      _isLoading = true;
    });
    final logs = await DatabaseHelper.instance.getHealthLogs(bird.id);
    setState(() {
      _alerts = HealthRuleEngine.evaluateLogs(logs);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 60, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bird Care',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '100% offline bird care log',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.wifi_off, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Offline', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_allBirds.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _allBirds.map((bird) {
                            final isSelected = bird.id == _selectedBird?.id;
                            return GestureDetector(
                              onTap: () => _switchBird(bird),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.secondary : Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      bird.gender == 'Male' ? '♂ ' : (bird.gender == 'Female' ? '♀ ' : '🐦 '),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      bird.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Bird Hero Card or First Time Onboarding Card
                  if (_selectedBird != null)
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BirdDetailScreen(bird: _selectedBird!)),
                          ).then((_) => _loadDashboardData());
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                theme.cardColor,
                                theme.cardColor.withOpacity(0.9),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                                    child: const Text('🐦', style: TextStyle(fontSize: 30)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedBird!.name,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${_selectedBird!.species} • ${_selectedBird!.color ?? "No color recorded"}',
                                          style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('Weight', '${_selectedBird!.weight?.toStringAsFixed(1) ?? "--"} g', Icons.monitor_weight_outlined),
                                  _buildStatItem('Sex', _selectedBird!.gender, Icons.wc_outlined),
                                  _buildStatItem('Status', _alerts.isEmpty ? 'Good' : 'Check', Icons.favorite_outline),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      color: AppColors.primary.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text('🐦', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 10),
                            const Text(
                              'Welcome to Bird Care',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'No birds yet. Add your first bird to start tracking health, weight, and a daily diary.',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddEditBirdScreen()),
                                ).then((_) => _loadDashboardData());
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Add your first bird'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Health Rule Engine Alerts Banner
                  if (_alerts.isNotEmpty) ...[
                    ..._alerts.map((alert) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: alert.severity == HealthAlertSeverity.danger
                                ? AppColors.dangerRed.withOpacity(0.12)
                                : AppColors.limitYellow.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: alert.severity == HealthAlertSeverity.danger ? AppColors.dangerRed : AppColors.limitYellow,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                alert.severity == HealthAlertSeverity.danger ? Icons.error_outline : Icons.warning_amber_rounded,
                                color: alert.severity == HealthAlertSeverity.danger ? AppColors.dangerRed : AppColors.limitYellow,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: alert.severity == HealthAlertSeverity.danger ? AppColors.dangerRed : AppColors.limitYellow,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      alert.message,
                                      style: const TextStyle(fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                  ],

                  // Quick Action Shortcuts
                  const Text(
                    'Quick actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.health_and_safety_outlined,
                          color: AppColors.primary,
                          label: 'Log health',
                          onTap: () {
                            if (_selectedBird != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddHealthLogScreen(bird: _selectedBird!)),
                              ).then((_) => _loadDashboardData());
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddEditBirdScreen()),
                              ).then((_) => _loadDashboardData());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.edit_note_outlined,
                          color: AppColors.secondary,
                          label: 'Add diary',
                          onTap: () {
                            if (_selectedBird != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddDiaryScreen(bird: _selectedBird!)),
                              ).then((_) => _loadDashboardData());
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddEditBirdScreen()),
                              ).then((_) => _loadDashboardData());
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.restaurant_menu_outlined,
                          color: AppColors.safeGreen,
                          label: 'Food guide',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FoodLibraryScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Today's Care Checklist
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Today’s care list',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_todayChecklist.values.where((v) => v).length}/${_todayChecklist.length} done',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          ..._todayChecklist.keys.map((task) {
                            final isDone = _todayChecklist[task]!;
                            return CheckboxListTile(
                              value: isDone,
                              activeColor: AppColors.primary,
                              title: Text(
                                task,
                                style: TextStyle(
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                  color: isDone ? Colors.grey : null,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _todayChecklist[task] = val ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
