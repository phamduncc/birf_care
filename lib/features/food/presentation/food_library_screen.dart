import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../models/food_item.dart';

class FoodLibraryScreen extends StatefulWidget {
  const FoodLibraryScreen({super.key});

  @override
  State<FoodLibraryScreen> createState() => _FoodLibraryScreenState();
}

class _FoodLibraryScreenState extends State<FoodLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FoodItem> _foods = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Safe', 'Limit', 'Dangerous'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.getFoods(
      category: _selectedCategory,
      query: _searchQuery,
    );
    setState(() {
      _foods = list;
      _isLoading = false;
    });
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _selectedCategory = _categories[index];
    });
    _loadFoods();
  }

  void _showFoodDetails(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final color = food.category == 'Safe'
            ? AppColors.safeGreen
            : (food.category == 'Limit' ? AppColors.limitYellow : AppColors.dangerRed);

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      food.category == 'Safe'
                          ? 'Safe'
                          : (food.category == 'Limit' ? 'Limit' : 'Toxic'),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      food.foodGroup,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                food.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (food.englishName != null)
                Text(
                  food.englishName!,
                  style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14),
                ),
              const Divider(height: 24),
              _buildDetailSection('Recommended portion', food.portion ?? 'See notes'),
              const SizedBox(height: 10),
              _buildDetailSection('How to prepare', food.preparation ?? 'Wash before feeding.'),
              const SizedBox(height: 10),
              _buildDetailSection('Important notes', food.warnings ?? 'No special notes.', isWarning: food.category != 'Safe'),
              const SizedBox(height: 10),
              _buildDetailSection('Details', food.description ?? ''),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isWarning ? AppColors.dangerRed : null)),
        const SizedBox(height: 4),
        Text(content, style: const TextStyle(fontSize: 13.5)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food library'),
        bottom: TabBar(
          controller: _tabController,
          onTap: _onCategoryChanged,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Safe'),
            Tab(text: 'Limit'),
            Tab(text: 'Toxic'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search foods (carrot, apple, chocolate)...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (val) {
                _searchQuery = val;
                _loadFoods();
              },
            ),
          ),

          // Food Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _foods.isEmpty
                    ? const Center(child: Text('No matching foods', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        itemCount: _foods.length,
                        itemBuilder: (context, index) {
                          final food = _foods[index];
                          final color = food.category == 'Safe'
                              ? AppColors.safeGreen
                              : (food.category == 'Limit' ? AppColors.limitYellow : AppColors.dangerRed);

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    food.category == 'Safe' ? '🟢' : (food.category == 'Limit' ? '🟡' : '🔴'),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      food.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  if (food.englishName != null) ...[
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        '(${food.englishName})',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${food.foodGroup} • ${food.portion ?? ""}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                              trailing: const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                              onTap: () => _showFoodDetails(food),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
