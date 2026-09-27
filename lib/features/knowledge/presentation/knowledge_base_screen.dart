import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/database_helper.dart';
import '../models/article.dart';
import 'article_detail_screen.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  List<Article> _articles = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<Map<String, String>> _categories = [
    {'id': 'All', 'label': 'All'},
    {'id': 'Basics', 'label': 'Basics'},
    {'id': 'Nutrition', 'label': 'Nutrition'},
    {'id': 'Hygiene', 'label': 'Hygiene'},
    {'id': 'Health', 'label': 'Health'},
    {'id': 'Behavior', 'label': 'Behavior'},
  ];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.getArticles(category: _selectedCategory);
    setState(() {
      _articles = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Care guides'),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat['id']!);
                        _loadArticles();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Articles List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                    ? const Center(child: Text('No articles in this category', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _articles.length,
                        itemBuilder: (context, index) {
                          final article = _articles[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.12),
                                child: const Icon(Icons.menu_book, color: AppColors.primary),
                              ),
                              title: Text(
                                article.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('${article.category} • ${article.readTimeMinutes} min read', style: const TextStyle(fontSize: 12)),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                                );
                              },
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
